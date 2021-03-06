--------------------------------------------------------
--  File created - Friday-April-06-2012   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Sequence POLLING_TEST_CLUSTER_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "TESTUSER"."POLLING_TEST_CLUSTER_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence POLLING_TEST_LOG_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "TESTUSER"."POLLING_TEST_LOG_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Table POLLING_TEST_OUTPUT
--------------------------------------------------------
CREATE TABLE POLLING_TEST_OUTPUT
(
  ID NUMBER NOT NULL,
  TEXTLINE VARCHAR2(255)
, CONSTRAINT POLLING_TEST_OUTPUT_PK PRIMARY KEY 
  (
    ID 
  )
  ENABLE 
);
--------------------------------------------------------
--  DDL for Table POLLING_TEST_CLUSTER
--------------------------------------------------------
  CREATE TABLE "TESTUSER"."POLLING_TEST_CLUSTER" 
   (	"ID" NUMBER, 
	"STATUS" VARCHAR2(50 BYTE), 
	"TEXTLINE" VARCHAR2(255 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  DDL for Table POLLING_TEST_LOG
--------------------------------------------------------

  CREATE TABLE "TESTUSER"."POLLING_TEST_LOG" 
   (	"ID" NUMBER, 
	"OLD_STATUS" VARCHAR2(50 BYTE), 
	"NEW_STATUS" VARCHAR2(50 BYTE), 
	"PTC_ID" NUMBER, 
	"CREATION_TS" TIMESTAMP (6)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  DDL for Index POLLING_TEST_LOG_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "TESTUSER"."POLLING_TEST_LOG_PK" ON "TESTUSER"."POLLING_TEST_LOG" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  DDL for Index POLLING_TEST_CLUSTER_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "TESTUSER"."POLLING_TEST_CLUSTER_PK" ON "TESTUSER"."POLLING_TEST_CLUSTER" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  Constraints for Table POLLING_TEST_CLUSTER
--------------------------------------------------------

  ALTER TABLE "TESTUSER"."POLLING_TEST_CLUSTER" ADD CONSTRAINT "POLLING_TEST_CLUSTER_PK" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "USERS"  ENABLE;
  ALTER TABLE "TESTUSER"."POLLING_TEST_CLUSTER" MODIFY ("STATUS" NOT NULL ENABLE);
  ALTER TABLE "TESTUSER"."POLLING_TEST_CLUSTER" MODIFY ("ID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table POLLING_TEST_LOG
--------------------------------------------------------

  ALTER TABLE "TESTUSER"."POLLING_TEST_LOG" ADD CONSTRAINT "POLLING_TEST_LOG_PK" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "USERS"  ENABLE;
  ALTER TABLE "TESTUSER"."POLLING_TEST_LOG" MODIFY ("ID" NOT NULL ENABLE);
--------------------------------------------------------
--  DDL for Trigger BI_POLLING_TEST_CLUSTER
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "TESTUSER"."BI_POLLING_TEST_CLUSTER" before
  INSERT ON "TESTUSER"."POLLING_TEST_CLUSTER" 
  FOR EACH row 
  BEGIN IF inserting THEN 
    IF :NEW."ID" IS NULL THEN
      SELECT POLLING_TEST_CLUSTER_SEQ.nextval INTO :NEW."ID" FROM dual;
    END IF;
  END IF;
END;
/
ALTER TRIGGER "TESTUSER"."BI_POLLING_TEST_CLUSTER" ENABLE;
--------------------------------------------------------
--  DDL for Trigger BI_POLLING_TEST_LOG
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "TESTUSER"."BI_POLLING_TEST_LOG" before
  INSERT ON "TESTUSER"."POLLING_TEST_LOG" 
  FOR EACH row 
  BEGIN IF inserting THEN 
    IF :NEW."ID" IS NULL THEN
      SELECT POLLING_TEST_LOG_SEQ.nextval INTO :NEW."ID" FROM dual;
    END IF;
    IF :NEW."CREATION_TS" IS NULL THEN
      SELECT SYSTIMESTAMP INTO :NEW."CREATION_TS" FROM dual;
    END IF;    
  END IF;
END;
/
ALTER TRIGGER "TESTUSER"."BI_POLLING_TEST_LOG" ENABLE;
--------------------------------------------------------
--  DDL for Trigger BU_POLLING_TEST_CLUSTER
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "TESTUSER"."BU_POLLING_TEST_CLUSTER" 
BEFORE UPDATE OF STATUS ON POLLING_TEST_CLUSTER 
FOR EACH ROW 
BEGIN
  POLLING_TEST_UTILS.WRITE_POLLING_TEST_LOG(:OLD.ID,:OLD.STATUS,:NEW.STATUS);
END;
/
ALTER TRIGGER "TESTUSER"."BU_POLLING_TEST_CLUSTER" ENABLE;
--------------------------------------------------------
--  DDL for Package POLLING_TEST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "TESTUSER"."POLLING_TEST_UTILS" AS 

  procedure write_polling_test_log(p_ptc_id in number, p_old_status in varchar2,p_new_status in varchar2);

END POLLING_TEST_UTILS;

/

--------------------------------------------------------
--  DDL for Package Body POLLING_TEST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TESTUSER"."POLLING_TEST_UTILS" AS

  procedure write_polling_test_log(p_ptc_id in number, p_old_status in varchar2,p_new_status in varchar2) AS
  pragma autonomous_transaction;
  BEGIN
    insert into POLLING_TEST_LOG (ptc_id,old_status,new_status) values (p_ptc_id,p_old_status,p_new_status);
	commit;
  END write_polling_test_log;

END POLLING_TEST_UTILS;

/

