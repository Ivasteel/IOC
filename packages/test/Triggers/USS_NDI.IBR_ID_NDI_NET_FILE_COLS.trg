/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NET_FILE_COLS
    BEFORE INSERT
    ON uss_ndi.ndi_net_file_cols
    FOR EACH ROW
BEGIN
    IF (:NEW.nnfc_id = 0) OR (:NEW.nnfc_id IS NULL)
    THEN
        :NEW.nnfc_id := ID_ndi_net_file_cols (:NEW.nnfc_id);
    END IF;
END;
/
