/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_PERSON_ASOPD_LINK
    BEFORE INSERT
    ON ikis_person.person_links
    FOR EACH ROW
    WHEN ((new.pal_id IS NULL) OR (new.pal_id = 0))
DECLARE
    FUNCTION getnextid
        RETURN NUMBER
    IS
        l_id   NUMBER;
    BEGIN
        SELECT ikis_person.sq_pal_id.NEXTVAL INTO l_id FROM DUAL;

        RETURN l_id;
    END getnextid;
BEGIN
    :new.pal_id := getnextid;
END;
/
