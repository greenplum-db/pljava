\c pljava_test pljava_test
set TIMEZONE=UTC;
set search_path = javatest, public;
set client_min_messages = "info";

-- org.postgresql.pljava.example.Parameters

select abs(extract('epoch' from (current_timestamp - javatest.java_getTimestamp()))::int) <= 2;
select abs(extract('epoch' from (current_timestamp - javatest.java_getTimestamptz()))::int) <= 2;

SELECT javatest.print('2016-01-01'::date);
SELECT javatest.print('2016-01-01'::date) FROM javatest.test;
SELECT * FROM javatest.print('2016-01-01'::date);

SELECT javatest.print('12:34:56-00'::time);
SELECT javatest.print('12:34:56-00'::time) FROM javatest.test;
SELECT * FROM javatest.print('12:34:56-00'::time);

SELECT javatest.print('2016-02-14 08:09:10'::timestamp);
SELECT javatest.print('2016-02-14 08:09:10'::timestamp) FROM javatest.test;
SELECT * FROM javatest.print('2016-02-14 08:09:10'::timestamp);
 
SELECT javatest.print('varchar'::varchar);
SELECT javatest.print('varchar'::varchar) FROM javatest.test;
SELECT * FROM javatest.print('varchar'::varchar);

SELECT encode(javatest.print('bytea'::bytea), 'escape');
SELECT encode(javatest.print('bytea'::bytea), 'escape') FROM javatest.test;
SELECT * FROM encode(javatest.print('bytea'::bytea), 'escape');

SELECT javatest.print(1::int2);
SELECT javatest.print(2::int2) FROM javatest.test;
SELECT * FROM javatest.print(3::int2);

SELECT javatest.print('{1,2,3}'::int2[]);
SELECT javatest.print('{2,3,4}'::int2[]) FROM javatest.test;
SELECT * FROM javatest.print('{3,4,5}'::int2[]);

SELECT javatest.print(4::int4);
SELECT javatest.print(5::int4) FROM javatest.test;
SELECT * FROM javatest.print(6::int4);

SELECT javatest.print('{4,5,6}'::int4[]);
SELECT javatest.print('{5,6,7}'::int4[]) FROM javatest.test;
SELECT * FROM javatest.print('{6,7,8}'::int4[]);

SELECT javatest.print(8::int8);
SELECT javatest.print(9::int8) FROM javatest.test;
SELECT * FROM javatest.print(10::int8);

SELECT javatest.print('{8,9,10}'::int8[]);
SELECT javatest.print('{9,10,11}'::int8[]) FROM javatest.test;
SELECT * FROM javatest.print('{10,11,12}'::int8[]);

SELECT javatest.print(11.12::float4);
SELECT javatest.print(12.13::float4) FROM javatest.test;
SELECT * FROM javatest.print(13.14::float4);

SELECT javatest.print('{11.1,12.2,13.3}'::float4[]);
SELECT javatest.print('{12.2,13.3,14.4}'::float4[]) FROM javatest.test;
SELECT * FROM javatest.print('{13.4,14.4,15.5}'::float4[]);

SELECT javatest.print(15.5::float8);
SELECT javatest.print(16.6::float8) FROM javatest.test;
SELECT * FROM javatest.print(17.7::float8);

SELECT javatest.print('{15.5,16.6,17.7}'::float8[]);
SELECT javatest.print('{16.6,17.7,18.8}'::float8[]) FROM javatest.test;
SELECT * FROM javatest.print('{17.7,18.8,19.9}'::float8[]);

SELECT javatest.printObj('{17,18,19}'::int[]);
SELECT javatest.printObj('{18,19,null,20}'::int[]) FROM javatest.test;
SELECT * FROM javatest.printObj('{19,null,20,21}'::int[]);

SELECT javatest.java_addOne(20);
SELECT javatest.java_addOne(21) FROM javatest.test;
SELECT * FROM javatest.java_addOne(22);

SELECT javatest.nullOnEven(23);
SELECT javatest.nullOnEven(24);
SELECT javatest.nullOnEven(25) FROM javatest.test;
SELECT javatest.nullOnEven(26) FROM javatest.test;
SELECT * FROM javatest.nullOnEven(27);
SELECT * FROM javatest.nullOnEven(28);

SELECT javatest.addNumbers(1::int2,2::int4,3::int8,4::numeric,5::numeric,6::float4,7::float8);
SELECT javatest.addNumbers(2::int2,2::int4,3::int8,4::numeric,5::numeric,6::float4,7::float8) FROM javatest.test;

select javatest.countnulls('{1,2,null,3,4}'::int[]);
select javatest.countnulls('{1,2,null,3,null,4}'::int[]) FROM javatest.test;

-- Functions over system calls

SELECT javatest.java_getSystemProperty('user.language');

-- org.postgresql.pljava.example.Security

-- start_matchsubs

-- m/ERROR\:.* \(JNICalls\.c:\d+\)/
-- s/\(JNICalls\.c:\d+\)//

-- end_matchsubs

/*
 * This function should fail since file system access is
 * prohibited when the language is trusted.
 */
SELECT javatest.create_temp_file_trusted();
SELECT javatest.create_temp_file_trusted() FROM javatest.test;
SELECT * FROM javatest.create_temp_file_trusted();

-- org.postgresql.pljava.example.TupleReturn

select base, incbase from javatest.tupleReturnExample(2,4);
select base, incbase from javatest.tupleReturnExample2(3,5);
select split_part(javatest.tupleReturnToString(javatest.tupleReturnExample(4,6)), ',', 1);
select split_part(javatest.tupleReturnToString(javatest.tupleReturnExample(5,7)), ',', 2);
select base, incbase from javatest.setReturnExample(6,8);

-- org.postgresql.pljava.example.HugeResultSet

select sum(base), count(*) from javatest.hugeResult(10000);
select sum(base), count(*) from javatest.hugeNonImmutableResult(10000);

-- org.postgresql.pljava.example.Users
select count(*) > 0 from javatest.listSupers();
select count(*) > 0 from javatest.listNonSupers();
select usename, usesuper from javatest.listNonSupers() where usename = 'pljava_test';

-- org.postgresql.pljava.example.UsingProperties

select * from javatest.propertyExample();

-- org.postgresql.pljava.example.UsingPropertiesAsResultSet

select * from javatest.resultSetPropertyExample();
select * from javatest.scalarPropertyExample();

-- org.postgresql.pljava.example.RandomInts

select count(*) from javatest.randomInts(123);

-- org.postgresql.pljava.example.LoggerTest

-- pg_regress cannot parse Java timestamp, so we put the message that won't be
-- displayed just to make sure the function runs well and returns no error
select javatest.logMessage('FINE', '123');

-- org.postgresql.pljava.example.BinaryColumnTest

select count(*) from javatest.binaryColumnTest();

-- org.postgresql.pljava.example.MetaDataBooleans

select * from javatest.getMetaDataBooleans() where method_name in ('isReadOnly', 'supportsColumnAliasing');

-- org.postgresql.pljava.example.MetaDataStrings

select * from javatest.getMetaDataStrings() where method_name in ('getDatabaseProductName', 'getDriverName');

-- org.postgresql.pljava.example.MetaDataInts

select * from javatest.getMetaDataInts() where method_name in ('getMaxRowSize', 'getMaxColumnsInTable');

-- org.postgresql.pljava.example.MetaDataTest

select 'public;' in (select javatest.callMetaDataMethod('getSchemas()')) as q;

-- org.postgresql.pljava.example.ResultSetTest

select javatest.executeSelect('select generate_series(1,10) as a');

-- org.postgresql.pljava.example.SetOfRecordTest

select * from javatest.executeSelectToRecords('select id, ''test'' || id as id2 from generate_series(1,11) as id') t(a varchar, b varchar);

-- org.postgresql.pljava.example.AnyTest

select javatest.loganyelement(1::int);
select javatest.loganyelement('a'::varchar);
select encode(javatest.loganyelement('b'::bytea), 'escape');

select javatest.makearray(1::int);
select javatest.makearray('a'::varchar);

-- org.postgresql.pljava.example.SPIActions

SELECT javatest.transferPeople(1);
SELECT * FROM employees1 order by id;
SELECT id,name, salary FROM employees2 order by id;

-- start_matchsubs

-- m/ERROR\:.* \(SOMEFILE\:SOMEFUNC\)/
-- s/\(SOMEFILE\:SOMEFUNC\)//

-- end_matchsubs

SELECT javatest.transferPeople(1) FROM javatest.test;  -- should error

select javatest.maxFromSetReturnExample(2,10);
select javatest.nestedStatements(5);
select javatest.testSavepointSanity();
select javatest.testTransactionRecovery();
select javatest.getDateAsString()::date is not null;
select javatest.getTimeAsString()::time is not null;
