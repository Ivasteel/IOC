/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.RDM$DELIVERY
IS
END;
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.RDM$DELIVERY
IS
    PROCEDURE InsertDelivery (p_nd_id        IN OUT NUMBER,
                              p_nd_code      IN     VARCHAR,
                              p_nd_tp        IN     VARCHAR,
                              p_nd_comment   IN     VARCHAR,
                              p_nd_npo       IN     NUMBER)
    IS
    BEGIN
        INSERT INTO ndi_delivery (nd_id,
                                  nd_code,
                                  nd_tp,
                                  nd_comment,
                                  nd_npo)
             VALUES (p_nd_id,
                     p_nd_code,
                     p_nd_tp,
                     p_nd_comment,
                     p_nd_npo)
          RETURNING nd_id
               INTO p_nd_id;
    END;

    PROCEDURE UpdateDelivery (p_nd_id        IN OUT NUMBER,
                              p_nd_code      IN     VARCHAR,
                              p_nd_tp        IN     VARCHAR,
                              p_nd_comment   IN     VARCHAR,
                              p_nd_npo       IN     NUMBER,
                              p_nd_st        IN     VARCHAR)
    IS
    BEGIN
        UPDATE ndi_delivery
           SET nd_code = p_nd_code,
               nd_tp = p_nd_tp,
               nd_comment = p_nd_comment,
               nd_npo = p_nd_npo,
               nd_st = p_nd_st
         WHERE nd_id = p_nd_id;
    END;

    PROCEDURE DeleteDelivery (p_nd_id IN OUT NUMBER)
    IS
    BEGIN
        UPDATE ndi_delivery
           SET nd_st = 'H'
         WHERE nd_id = p_nd_id;
    END;
END;
/