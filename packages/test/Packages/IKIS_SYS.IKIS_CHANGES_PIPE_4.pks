/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_CHANGES_PIPE_4
    AUTHID CURRENT_USER
IS
    -- Author  : RYABA
    -- Created : 11.03.2005 15:27:49
    -- Purpose :

    TYPE CRef IS REF CURSOR;

    FUNCTION ESS_AUD_LIST (p_ead IN NUMBER, p_id IN NUMBER)
        RETURN numset_t
        PIPELINED;
END IKIS_CHANGES_PIPE_4;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_CHANGES_PIPE_4 FOR IKIS_SYS.IKIS_CHANGES_PIPE_4
/


GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_PIPE_4 TO II01RC_IKIS_AUDIT_VIEW
/


/* Formatted on 8/12/2025 6:10:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_CHANGES_PIPE_4
IS
    FUNCTION ESS_AUD_LIST (p_ead IN NUMBER, p_id IN NUMBER)
        RETURN numset_t
        PIPELINED
    IS
        Result   NUMBER;
        l_cur    CRef;
        l_id     TEssAud := TEssAud (NULL, NULL);
    BEGIN
        l_id.ESS_CODE := p_ead;
        l_id.ESS_ID := p_id;
        PIPE ROW (l_id);

        FOR vEss IN (SELECT ead_id, ead_chield_SQL
                       FROM v_ikis_ess_aud_code
                      WHERE ead_ead = p_ead)
        LOOP
            l_id.ess_code := vEss.ead_id;

            OPEN l_cur FOR vEss.ead_chield_SQL USING p_id;

            FETCH l_cur INTO l_id.ess_id;

            WHILE (NOT l_cur%NOTFOUND)
            LOOP
                PIPE ROW (l_id);

                FETCH l_cur INTO l_id.ess_id;
            END LOOP;

            CLOSE l_cur;
        END LOOP;

        RETURN;
    END ESS_AUD_LIST;
END IKIS_CHANGES_PIPE_4;
/