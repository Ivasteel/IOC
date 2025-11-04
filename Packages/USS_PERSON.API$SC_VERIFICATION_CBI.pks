/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_VERIFICATION_CBI
IS
    -- Author  : SHOSTAK
    -- Created : 22.12.2024 14:51:46
    -- Purpose : Верифікація даних, що надходять від ЦБІ

    /*
    info:    Пошук відповідностей в довіднику ДЗР
    author:  sho
    */
    PROCEDURE Set_Wares_Wrn (p_Scdi_Id IN NUMBER, p_Scv_Id IN NUMBER);

    PROCEDURE Set_Scdi_Sc (p_Scdi_Id   IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
                           p_Scdi_Sc   IN Sc_Pfu_Data_Ident.Scdi_Sc%TYPE);
END Api$sc_Verification_Cbi;
/


GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION_CBI TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION_CBI TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION_CBI TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION_CBI TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.Api$sc_Verification_Cbi
IS
    /*
    info:    Пошук відповідностей в довіднику ДЗР
    author:  sho
    */
    PROCEDURE Set_Wares_Wrn (p_Scdi_Id IN NUMBER, p_Scv_Id IN NUMBER)
    IS
        l_Hs   NUMBER := Tools.Gethistsession;
    BEGIN
        FOR Rec IN (SELECT Sccw_Id, Sccw_Iso, Sccw_Name
                      FROM Sc_Cbi_Wares w
                     WHERE w.Sccw_Scdi = p_Scdi_Id)
        LOOP
            DECLARE
                l_Wrn_Id   NUMBER;
            BEGIN
                BEGIN
                      SELECT c.Wrn_Id
                        INTO l_Wrn_Id
                        FROM Uss_Ndi.v_Ndi_Cbi_Wares c
                       WHERE     c.Wrn_Shifr = Rec.Sccw_Iso
                             AND c.History_Status = 'A'
                             --AND c.Wrn_St = 'A'--для данних від ЦБІ шукати навіть в історичних данних
                             AND UTL_MATCH.Edit_Distance_Similarity (
                                     UPPER (TRIM (c.Wrn_Name)),
                                     UPPER (TRIM (Rec.Sccw_Name))) >=
                                   100
                                 * (    LENGTH (
                                            TRIM (c.Wrn_Name || Rec.Sccw_Name))
                                      / 2
                                    - 2)
                                 /             -- (-2 = отличие в два символа)
                                   (  LENGTH (
                                          TRIM (c.Wrn_Name || Rec.Sccw_Name))
                                    / 2)
                    ORDER BY UTL_MATCH.Edit_Distance_Similarity (
                                 UPPER (TRIM (Rec.Sccw_Name)),
                                 UPPER (TRIM (c.Wrn_Name))) DESC
                       FETCH FIRST ROW ONLY;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        Api$sc_Verification.Set_Not_Verified (
                            p_Scv_Id    => p_Scv_Id,
                            p_Scvl_Hs   => l_Hs,
                            p_Error     =>
                                   CHR (38)
                                || '364#'
                                || Rec.Sccw_Iso
                                || '#'
                                || Rec.Sccw_Name);
                        RETURN;
                END;

                UPDATE Sc_Cbi_Wares w
                   SET w.Sccw_St =
                           CASE
                               WHEN l_Wrn_Id IS NOT NULL THEN 'VO'
                               ELSE 'VE'
                           END,
                       w.Sccw_Wrn = l_Wrn_Id
                 WHERE w.Sccw_Id = Rec.Sccw_Id;
            END;
        END LOOP;

        Api$sc_Verification.Set_Ok (p_Scv_Id => p_Scv_Id, p_Scvl_Hs => l_Hs);
    END;

    PROCEDURE Set_Scdi_Sc (p_Scdi_Id   IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
                           p_Scdi_Sc   IN Sc_Pfu_Data_Ident.Scdi_Sc%TYPE)
    IS
    BEGIN
        UPDATE Sc_Pfu_Data_Ident
           SET Scdi_Sc = p_Scdi_Sc
         WHERE Scdi_Id = p_Scdi_Id AND Scdi_Sc IS NULL;

        IF SQL%ROWCOUNT > 0
        THEN
            UPDATE Sc_Pfu_Address t
               SET Scpa_Sc = p_Scdi_Sc
             WHERE Scpa_Scdi = p_Scdi_Id;

            UPDATE Sc_Pfu_Document t
               SET Scpo_Sc = p_Scdi_Sc
             WHERE Scpo_Scdi = p_Scdi_Id;
        END IF;
    END;
END Api$sc_Verification_Cbi;
/