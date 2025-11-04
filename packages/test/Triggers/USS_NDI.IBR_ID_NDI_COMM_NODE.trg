/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_COMM_NODE
    BEFORE INSERT
    ON uss_ndi.ndi_comm_node
    FOR EACH ROW
BEGIN
    IF (:NEW.ncn_id = 0) OR (:NEW.ncn_id IS NULL)
    THEN
        :NEW.ncn_id := ID_ndi_comm_node (:NEW.ncn_id);
    END IF;
END;
/
