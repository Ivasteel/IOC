/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NET_FILES
    BEFORE INSERT
    ON uss_ndi.ndi_net_files
    FOR EACH ROW
BEGIN
    IF (:NEW.nnf_id = 0) OR (:NEW.nnf_id IS NULL)
    THEN
        :NEW.nnf_id := ID_ndi_net_files (:NEW.nnf_id);
    END IF;
END;
/
