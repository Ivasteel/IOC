/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_METADATA_EDIT
IS
    -- Author  : MAXYM
    -- Created : 08.11.2017 10:55:06
    -- Purpose :

    PROCEDURE SetCell (p_rcs_rct       IN rtp_cell_spec.rcs_rct%TYPE,
                       p_rcs_rrt       IN rtp_cell_spec.rcs_rrt%TYPE,
                       p_rcs_tp        IN rtp_cell_spec.rcs_tp%TYPE,
                       p_rcs_formula   IN rtp_cell_spec.rcs_formula%TYPE);

    PROCEDURE DeleteCell (p_rcs_rct   IN rtp_cell_spec.rcs_rct%TYPE,
                          p_rcs_rrt   IN rtp_cell_spec.rcs_rrt%TYPE);
END FINZVIT_METADATA_EDIT;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_METADATA_EDIT TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_METADATA_EDIT
IS
    PROCEDURE SetCell (p_rcs_rct       IN rtp_cell_spec.rcs_rct%TYPE,
                       p_rcs_rrt       IN rtp_cell_spec.rcs_rrt%TYPE,
                       p_rcs_tp        IN rtp_cell_spec.rcs_tp%TYPE,
                       p_rcs_formula   IN rtp_cell_spec.rcs_formula%TYPE)
    IS
    BEGIN
        UPDATE rtp_cell_spec
           SET rcs_formula = p_rcs_formula, rcs_tp = p_rcs_tp
         WHERE rcs_rct = p_rcs_rct AND rcs_rrt = p_rcs_rrt;

        IF (SQL%ROWCOUNT = 0)
        THEN
            INSERT INTO rtp_cell_spec (rcs_rct,
                                       rcs_rrt,
                                       rcs_formula,
                                       rcs_tp)
                 VALUES (p_rcs_rct,
                         p_rcs_rrt,
                         p_rcs_formula,
                         p_rcs_tp);
        END IF;
    END;

    PROCEDURE DeleteCell (p_rcs_rct   IN rtp_cell_spec.rcs_rct%TYPE,
                          p_rcs_rrt   IN rtp_cell_spec.rcs_rrt%TYPE)
    IS
    BEGIN
        DELETE rtp_cell_spec
         WHERE rcs_rct = p_rcs_rct AND rcs_rrt = p_rcs_rrt;
    END;
END FINZVIT_METADATA_EDIT;
/