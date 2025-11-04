/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.DNET$STATS
IS
    -- Author  : SHOSTAK
    -- Created : 12/10/2021 4:18:25 PM
    -- Purpose :

    PROCEDURE Get_Sc_Stats (p_Cur OUT SYS_REFCURSOR);
END Dnet$stats;
/


GRANT EXECUTE ON USS_PERSON.DNET$STATS TO DNET_PROXY
/

GRANT EXECUTE ON USS_PERSON.DNET$STATS TO II01RC_USS_PERSON_WEB
/


/* Formatted on 8/12/2025 5:57:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.DNET$STATS
IS
    PROCEDURE Get_Sc_Stats (p_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Cur FOR
            SELECT 'Кількість соціальних карток' AS Caption, COUNT (*) AS Cnt
              FROM Socialcard c
             WHERE c.Sc_St = '1'
            UNION ALL
            SELECT 'Кількість особових справ' AS Caption, COUNT (*) AS Cnt
              FROM Uss_Esr.v_Personalcase
            UNION ALL
            SELECT 'Кількість документів' AS Caption, COUNT (*) AS Cnt
              FROM Sc_Document d
             WHERE d.Scd_St IN ('1', 'A')
            UNION ALL
            SELECT 'Кількість сканів' AS Caption, COUNT (*) AS Cnt
              FROM Uss_Doc.v_Files f;
    END;
END Dnet$stats;
/