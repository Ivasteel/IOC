/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PACKET_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_packet_type
    FOR EACH ROW
BEGIN
    IF (:NEW.pat_id = 0) OR (:NEW.pat_id IS NULL)
    THEN
        :NEW.pat_id := ID_ndi_packet_type (:NEW.pat_id);
    END IF;
END;
/
