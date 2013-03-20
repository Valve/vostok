require 'spec_helper'

describe 'vostok' do
  it 'should return version' do
    Vostok::VERSION.should_not be_nil
  end

  let(:import){import =  Vostok::Import.new(host: 'localhost', dbname: 'db1')}
  it 'should take connection hash to constructor' do
    import.should_not be_nil
  end

  it 'should assign connection' do
    import.connection.should_not be_nil
  end

  it 'should assign connection with hash' do
    import.connection.should be_instance_of ::Hash
  end

  context 'importing' do
    it 'should throw argument error when no table name given' do
      ->{import.start(nil, nil, nil)}.should raise_error ArgumentError
      ->{import.start('', nil, nil)}.should raise_error ArgumentError
    end

    it 'should throw argument error when no column names are given' do
      ->{import.start(:customers, nil, nil)}.should raise_error ArgumentError
    end

    it 'should throw argument error when column names is empty array' do
      ->{import.start(:customers, [], nil)}.should raise_error ArgumentError
    end

    it 'should throw argument error when column names are not equal to values' do
      ->{import.start(:customers, [:a, :b], [[1,2,3], [1,2,3]])}.should raise_error ArgumentError
    end

    it 'should open pg_connection if it is not yet open' do
      mock_connection = mock 'connection', close: true
      mock_connection.stub!(:exec)
      PG::Connection.should_receive(:open).and_return mock_connection
      import.start(:customers, [:a], [[1]])
    end

    it 'should call PG library with correct sql in one go' do
      sql = <<-eos
        insert into "customers" ("a","b") values('1','2'),('3','4')
      eos
      mock_connection = mock 'connection', close: true
      PG::Connection.stub!(:open).and_return mock_connection
      mock_connection.should_receive(:exec).with(sql.strip)
      import.start(:customers, [:a, :b], [[1,2], [3,4]])
    end

    it 'should partition sql into subquries per batch_size' do
      data = [[1,2], [3,4], [5,6], [7,8], [9,10]]
      sql1 = <<-eos
        insert into "customers" ("a","b") values('1','2'),('3','4')
      eos
      sql2 = <<-eos
        insert into "customers" ("a","b") values('5','6'),('7','8')
      eos
      sql3 = <<-eos
        insert into "customers" ("a","b") values('9','10')
      eos
      mock_connection = mock 'connection', close: true
      PG::Connection.stub!(:open).and_return mock_connection
      mock_connection.should_receive(:exec).with(sql1.strip).ordered
      mock_connection.should_receive(:exec).with(sql2.strip).ordered
      mock_connection.should_receive(:exec).with(sql3.strip).ordered
      import.start(:customers, [:a, :b], data, batch_size: 2)
    end

    it 'should return number of inserted rows' do
      mock_connection = mock 'connection', close: true
      PG::Connection.stub!(:open).and_return mock_connection
      mock_connection.stub!(:exec)
      import.start(:customers, [:a, :b], [[1,2]]).should == 1
    end

    it 'should close the connection' do
      mock_connection = mock 'connection'
      PG::Connection.stub!(:open).and_return mock_connection
      mock_connection.stub!(:exec)
      mock_connection.should_receive(:close)
      import.start(:customers, [:a, :b], [[1,2]])
    end
  end
end