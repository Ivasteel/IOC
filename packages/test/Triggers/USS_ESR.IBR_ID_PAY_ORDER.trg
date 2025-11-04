/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PAY_ORDER
    BEFORE INSERT
    ON uss_esr.pay_order
    FOR EACH ROW
BEGIN
    IF (:NEW.po_id = 0) OR (:NEW.po_id IS NULL)
    THEN
        :NEW.po_id := ID_pay_order (:NEW.po_id);
    END IF;
END;
/
