/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_SRC_DESTROYED_PROP
    BEFORE INSERT
    ON uss_esr.src_destroyed_prop
    FOR EACH ROW
BEGIN
    IF (:NEW.sdp_id = 0) OR (:NEW.sdp_id IS NULL)
    THEN
        :NEW.sdp_id := ID_src_destroyed_prop (:NEW.sdp_id);
    END IF;
END;
/
