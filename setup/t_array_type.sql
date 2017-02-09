--------------------------------------------------------
--  DDL for Type T_ARRAY
--------------------------------------------------------

-- If type_name exists and has type dependents ignore error

BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE EDITIONABLE TYPE "T_ARRAY" is VARRAY(32767) OF VARCHAR2(32767);';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/