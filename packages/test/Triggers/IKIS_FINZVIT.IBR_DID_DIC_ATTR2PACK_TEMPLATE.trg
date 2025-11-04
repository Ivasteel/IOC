/* Formatted on 8/12/2025 6:06:33 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_FINZVIT.IBR_DID_dic_attr2pack_template
    BEFORE INSERT
    ON IKIS_FINZVIT.DIC_ATTR2PACK_TEMPLATE
    FOR EACH ROW
BEGIN
    :NEW.apt_id := DID_dic_attr2pack_template (:NEW.apt_id);
END;
/
