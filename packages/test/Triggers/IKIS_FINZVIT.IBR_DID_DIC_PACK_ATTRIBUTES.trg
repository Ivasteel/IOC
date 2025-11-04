/* Formatted on 8/12/2025 6:06:33 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_FINZVIT.IBR_DID_dic_pack_attributes
    BEFORE INSERT
    ON IKIS_FINZVIT.DIC_PACK_ATTRIBUTES
    FOR EACH ROW
BEGIN
    :NEW.pa_id := DID_dic_pack_attributes (:NEW.pa_id);
END;
/
