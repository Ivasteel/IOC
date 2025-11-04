/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_DID_EXCEPTION_LOG
    BEFORE INSERT
    ON USS_EXCH.EXCEPTION_LOG
    FOR EACH ROW
BEGIN
    :new.el_id := did_exception_log (:new.el_id);
END;
/
