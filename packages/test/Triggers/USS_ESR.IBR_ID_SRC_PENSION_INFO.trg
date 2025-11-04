/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_SRC_PENSION_INFO
    BEFORE INSERT
    ON uss_esr.src_pension_info
    FOR EACH ROW
BEGIN
    IF (:NEW.spi_id = 0) OR (:NEW.spi_id IS NULL)
    THEN
        :NEW.spi_id := ID_src_pension_info (:NEW.spi_id);
    END IF;
END;
/
