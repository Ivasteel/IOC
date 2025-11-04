/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.DNET$CMES
IS
    -- Author  : SHOSTAK
    -- Created : 01.06.2023 3:41:48 PM
    -- Purpose : Функції для отримання інформації з соцкарток для кабінету кейс-менеджера
    -- Пакет було створенов демонстраційних цілях щоб видати Реноме хоч якийсь API
    -- TODO: перенести до cmes$socialcard після уточнення постановки

    FUNCTION Get_Sc_Addr (p_Sc_Id IN NUMBER, p_Sca_Tp IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Get_Socialcard (p_Sc_Id           IN     NUMBER,
                              Pers_Info            OUT SYS_REFCURSOR,
                              Disability_Info      OUT SYS_REFCURSOR,
                              Death_Info           OUT SYS_REFCURSOR);


    PROCEDURE GET_SC_LIST (p_sc_unique   IN     VARCHAR2,
                           p_eos_num     IN     VARCHAR2,
                           p_pib         IN     VARCHAR2,
                           p_edrpou      IN     VARCHAR2,
                           p_passport    IN     VARCHAR2,
                           res_cur          OUT SYS_REFCURSOR,
                           p_birth_dt    IN     DATE DEFAULT NULL);
END Dnet$cmes;
/


GRANT EXECUTE ON USS_PERSON.DNET$CMES TO DNET_PROXY
/

GRANT EXECUTE ON USS_PERSON.DNET$CMES TO II01RC_USS_PERSON_PORTAL
/

GRANT EXECUTE ON USS_PERSON.DNET$CMES TO II01RC_USS_PERSON_WEB
/

GRANT EXECUTE ON USS_PERSON.DNET$CMES TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:57:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.DNET$CMES
IS
    FUNCTION Get_Sc_Addr (p_Sc_Id IN NUMBER, p_Sca_Tp IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
                                      SELECT    Sca_Postcode
                                             || ', '
                                             || a.Sca_Country
                                             || ', '
                                             || a.Sca_Region
                                             || ', '
                                             || a.Sca_District
                                             || ', '
                                             || a.Sca_City
                                             || ', '
                                             || a.Sca_Street
                                             || CASE
                                                    WHEN a.Sca_Building IS NOT NULL THEN ' буд. '
                                                    ELSE ' '
                                                END
                                             || a.Sca_Building
                                             || CASE
                                                    WHEN a.Sca_Apartment IS NOT NULL THEN ' кв. '
                                                    ELSE ' '
                                                END
                                             || a.Sca_Apartment    AS INTO l_Result
                                        FROM Sc_Address a
                                       WHERE     a.Sca_Sc = p_Sc_Id
                                             AND a.Sca_Tp = p_Sca_Tp
                                             AND a.History_Status = 'A'
                                       FETCH FIRST ROW ONLY;

        RETURN l_Result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    PROCEDURE Get_Person_Info (p_Sc_Id     IN     NUMBER,
                               Pers_Info      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Pers_Info FOR
            SELECT c.Sc_Id,
                      INITCAP (i.Sci_Ln)
                   || ' '
                   || INITCAP (i.Sci_Fn)
                   || ' '
                   || INITCAP (i.Sci_Mn)
                       AS Pib,
                   (  SELECT p.Scd_Seria || p.Scd_Number
                        FROM Sc_Document p
                       WHERE     p.Scd_Sc = c.Sc_Id
                             AND p.Scd_Ndt IN (6, 7, 37)
                             AND p.Scd_St IN ('A', '1')
                    ORDER BY (p.Scd_Start_Dt) DESC
                       FETCH FIRST ROW ONLY)
                       AS Doc_Num,
                   (  SELECT p.Scd_Seria || p.Scd_Number
                        FROM Sc_Document p
                       WHERE     p.Scd_Sc = c.Sc_Id
                             AND p.Scd_Ndt = 5
                             AND p.Scd_St IN ('A', '1')
                    ORDER BY (p.Scd_Start_Dt) DESC
                       FETCH FIRST ROW ONLY)
                       AS Numident,
                   (SELECT b.Scb_Dt
                      FROM Sc_Birth b
                     WHERE b.Scb_Id = Cc.Scc_Scb)
                       AS Birth_Dt,
                   (SELECT g.Dic_Name
                      FROM Uss_Ndi.v_Ddn_Gender g
                     WHERE g.Dic_Value = i.Sci_Gender)
                       AS Gender,
                   (SELECT n.Dic_Name
                      FROM Uss_Ndi.v_Ddn_Nationality n
                     WHERE n.Dic_Value = i.Sci_Nationality)
                       AS Nationality,
                   Get_Sc_Addr (c.Sc_Id, '3')
                       AS Address_Reg,
                   Get_Sc_Addr (c.Sc_Id, '2')
                       AS Address_Fact,
                   (SELECT NVL (t.Sct_Phone_Mob, t.Sct_Phone_Num)
                      FROM Sc_Contact t
                     WHERE t.Sct_Id = Cc.Scc_Sct
                     FETCH FIRST ROW ONLY)
                       AS Phone
              FROM Socialcard  c
                   JOIN Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
                   JOIN Sc_Identity i ON Cc.Scc_Sci = i.Sci_Id
             WHERE c.Sc_Id = p_Sc_Id;
    END;

    PROCEDURE Get_Disbility_Info (p_Sc_Id           IN     NUMBER,
                                  Disability_Info      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Disability_Info FOR
              SELECT d.Scy_Group AS "Group", d.Scy_Reason AS Reason
                FROM Sc_Disability d
               WHERE d.Scy_Sc = p_Sc_Id AND d.History_Status = 'A'
            ORDER BY d.Scy_Start_Dt DESC
               FETCH FIRST ROW ONLY;
    END;

    PROCEDURE Get_Death_Info (p_Sc_Id      IN     NUMBER,
                              Death_Info      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Death_Info FOR
              SELECT d.Sch_Dt AS Death_Dt, d.Sch_Is_Dead AS Is_Dead
                FROM Socialcard c
                     JOIN Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
                     JOIN Sc_Death d
                         ON Cc.Scc_Sch = d.Sch_Id AND Cc.Scc_Sch <> -1
               WHERE c.Sc_Id = p_Sc_Id
            ORDER BY d.Sch_Dt
               FETCH FIRST ROW ONLY;
    END;

    PROCEDURE Get_Socialcard (p_Sc_Id           IN     NUMBER,
                              Pers_Info            OUT SYS_REFCURSOR,
                              Disability_Info      OUT SYS_REFCURSOR,
                              Death_Info           OUT SYS_REFCURSOR)
    IS
    BEGIN
        Get_Person_Info (p_Sc_Id, Pers_Info);
        Get_Disbility_Info (p_Sc_Id, Disability_Info);
        Get_Death_Info (p_Sc_Id, Death_Info);
    END;

    PROCEDURE GET_SC_LIST (p_sc_unique   IN     VARCHAR2,
                           p_eos_num     IN     VARCHAR2,
                           p_pib         IN     VARCHAR2,
                           p_edrpou      IN     VARCHAR2,
                           p_passport    IN     VARCHAR2,
                           res_cur          OUT SYS_REFCURSOR,
                           p_birth_dt    IN     DATE DEFAULT NULL)
    IS
    BEGIN
        dnet$socialcard.GET_SC_LIST (p_sc_unique   => p_sc_unique,
                                     p_eos_num     => p_eos_num,
                                     p_pib         => p_pib,
                                     p_edrpou      => p_edrpou,
                                     p_passport    => p_passport,
                                     p_birth_dt    => p_birth_dt,
                                     res_cur       => res_cur);
    END;
END Dnet$cmes;
/