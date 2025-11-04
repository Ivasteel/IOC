/* Formatted on 8/12/2025 6:12:49 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_WEBPROXY."BI_DEMO_USERS"
    BEFORE INSERT
    ON IKIS_WEBPROXY.DEMO_USERS
    FOR EACH ROW
BEGIN
    BEGIN
        FOR c1 IN (SELECT DEMO_USERS_SEQ.NEXTVAL next_val FROM DUAL)
        LOOP
            :new.USER_ID := c1.next_val;
            :new.admin_user := 'N';
            :new.created_on := SYSDATE;
        END LOOP;
    END;
END;
/
