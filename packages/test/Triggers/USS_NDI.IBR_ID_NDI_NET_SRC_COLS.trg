/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NET_SRC_COLS
    BEFORE INSERT
    ON uss_ndi.ndi_net_src_cols
    FOR EACH ROW
BEGIN
    IF (:NEW.nnsc_id = 0) OR (:NEW.nnsc_id IS NULL)
    THEN
        :NEW.nnsc_id := ID_ndi_net_src_cols (:NEW.nnsc_id);
    END IF;
END;
/
