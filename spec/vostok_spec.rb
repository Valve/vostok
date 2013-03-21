require 'spec_helper'

describe 'vostok' do
  before {
    connection_stub = stub 'connection', reset: true, close: true
    connection_stub.stub(:is_a?).with(PG::Connection).and_return(true)
    connection_stub.stub(:is_a?).with(Hash).and_return(false)
    PG::Connection.stub(:new).and_return(connection_stub)
  }
  let(:import){import =  Vostok::Import.new(host: 'localhost', dbname: 'db1')}

  it 'should return version' do
    Vostok::VERSION.should_not be_nil
  end


  it 'should throw argument error when no connection is given' do
    ->{Vostok::Import.new(nil)}.should raise_error ArgumentError
  end

  it 'should throw argument error when given connection is not a hash or a PG::Connection' do
    ->{Vostok::Import.new(1)}.should raise_error ArgumentError
  end 

  it 'should accept connection hash in constructor' do
    import =  Vostok::Import.new(host: 'localhost', dbname: 'db1')
    import.should_not be_nil
  end

  it 'should accept existing PG connection in constructor' do
    pg_connection = PG::Connection.new(host: 'localhost', dbname: 'db1')
    import = Vostok::Import.new(pg_connection)
    import.should_not be_nil
  end

  it 'should assign pg_connection' do
    import.pg_connection.should_not be_nil
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

    it 'should reset pg_connection if it is not yet open' do
      import.pg_connection.stub(:exec)
      import.pg_connection.should_receive(:reset)
      import.start(:customers, [:a], [[1]])
    end

    it 'should call PG library with correct sql in one go' do
      sql = <<-eos
        insert into "customers" ("a","b") values('1','2'),('3','4')
      eos
      import.pg_connection.should_receive(:exec).with(sql.strip)
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
      import.pg_connection.should_receive(:exec).with(sql1.strip).ordered
      import.pg_connection.should_receive(:exec).with(sql2.strip).ordered
      import.pg_connection.should_receive(:exec).with(sql3.strip).ordered
      import.start(:customers, [:a, :b], data, batch_size: 2)
    end

    it 'should return number of inserted rows' do
      import.pg_connection.stub(:exec)
      import.start(:customers, [:a, :b], [[1,2]]).should == 1
    end

    it 'should close the connection' do
      import.pg_connection.stub(:exec)
      import.pg_connection.should_receive(:close)
      import.start(:customers, [:a, :b], [[1,2]])
    end
  end
end