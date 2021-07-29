CREATE FUNCTION java_call_handler()  RETURNS language_handler AS '$libdir/pljava' LANGUAGE C;
CREATE TRUSTED LANGUAGE java HANDLER java_call_handler;
