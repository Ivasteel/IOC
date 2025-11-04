/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_VERIFICATION_DFS
IS
    -- Author  : KELATEV
    -- Created : 25.02.2025 15:08:51
    -- Purpose : Âåðèô³êàö³ÿ ÄÏÑ ÿêà âèêîíóºòüñÿ ó ïðîì³æíèõ ñòðóêòóðàõ

    FUNCTION Reg_Verify_Dfs_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                        p_Obj_Id   IN     NUMBER,
                                        p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Dfs_Rnokpp_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2);
END Api$sc_Verification_Dfs;
/


GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION_DFS TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:56:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_VERIFICATION_DFS
IS
    -----------------------------------------------------------------
    --         Ïîøóê ó îñîáè íàÿâíîñò³ ñâ³äîöòâà ïðî ñìåðòü â³ä ÄÐÀÖÑ
    -----------------------------------------------------------------
    PROCEDURE Search_Scdi_Death (p_Scdi_Id    IN     NUMBER,
                                 p_Death_Dt      OUT DATE,
                                 p_Cert_Num      OUT VARCHAR2,
                                 p_Cert_Dt       OUT DATE)
    IS
        l_Scdi                  Sc_Pfu_Data_Ident%ROWTYPE;
        l_Scdi_Cfg              Uss_Ndi.v_Ndi_Scdi_Config%ROWTYPE;
        l_Ipn_Invalid           BOOLEAN := FALSE;
        l_Pib_Mismatch_On_Ipn   BOOLEAN := FALSE;
        l_Dh_Id                 NUMBER;
    BEGIN
        SELECT *
          INTO l_Scdi
          FROM Sc_Pfu_Data_Ident
         WHERE Scdi_Id = p_Scdi_Id;

        SELECT *
          INTO l_Scdi_Cfg
          FROM Uss_Ndi.v_Ndi_Scdi_Config c
         WHERE c.Nsc_Nrt = l_Scdi.Scdi_Nrt;

        IF Api$scdi2sc.Search_Scdi_Sc (l_Scdi,
                                       l_Scdi_Cfg,
                                       l_Ipn_Invalid,
                                       l_Pib_Mismatch_On_Ipn)
        THEN
            /* SELECT MAX(b.Sch_Dt)
             INTO p_Death_Dt
             FROM Uss_Person.v_Socialcard t, Uss_Person.v_Sc_Change Ch, Uss_Person.v_Sc_Death b
            WHERE t.Sc_Id = l_Scdi.Scdi_Sc
              AND t.Sc_Src = '20' \*DRACS*\
              AND Ch.Scc_Id = t.Sc_Scc
              AND b.Sch_Id = Ch.Scc_Sch;*/

            --IF p_Death_Dt IS NOT NULL THEN
            SELECT MAX (d.Scd_Dh)
              INTO l_Dh_Id
              FROM Sc_Document d
             WHERE     d.Scd_Sc = l_Scdi.Scdi_Sc
                   AND d.Scd_Ndt = 89
                   AND d.Scd_St = '1'
                   AND d.Scd_Src = 'DRACS';

            IF l_Dh_Id IS NOT NULL
            THEN
                p_Death_Dt :=
                    Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                        p_Nda_Id   => 222,
                        p_Dh_Id    => l_Dh_Id);
                p_Cert_Num :=
                    Uss_Doc.Api$documents.Get_Attr_Val_Str (
                        p_Nda_Id   => 218,
                        p_Dh_Id    => l_Dh_Id);
                p_Cert_Dt :=
                    Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                        p_Nda_Id   => 221,
                        p_Dh_Id    => l_Dh_Id);
            END IF;
        --END IF;
        END IF;
    END;

    -----------------------------------------------------------------
    --         Ðåºñòðàö³ÿ çàïèòó äî ÄÏÑ (âåðèô³êàö³ÿ ÐÍÎÊÏÏ)
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Dfs_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                        p_Obj_Id   IN     NUMBER,
                                        p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id      NUMBER;

        l_Inn        VARCHAR2 (100);
        l_Birth_Dt   DATE;
        l_Ln         VARCHAR2 (250);
        l_Mn         VARCHAR2 (250);
        l_Fn         VARCHAR2 (250);
        l_Doc_Sn     Sc_Pfu_Data_Ident.Scdi_Doc_Sn%TYPE;
    BEGIN
        SELECT d.Scdi_Numident,
               d.Scdi_Fn,
               d.Scdi_Ln,
               d.Scdi_Mn,
               d.Scdi_Birthday,
               d.Scdi_Doc_Sn
          INTO l_Inn,
               l_Fn,
               l_Ln,
               l_Mn,
               l_Birth_Dt,
               l_Doc_Sn
          FROM Sc_Pfu_Data_Ident d
         WHERE Scdi_Id = p_Obj_Id;

        l_Inn :=
            NVL (
                l_Inn,
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Obj_Id,
                    p_Ndt_Id      => 5,
                    p_Nda_Class   => 'DSN'));
        l_Doc_Sn :=
            NVL (
                l_Doc_Sn,
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Obj_Id,
                    p_Nda_Class   => 'DSN',
                    p_Ndc_Id      => 13));
        l_Birth_Dt :=
            NVL (
                l_Birth_Dt,
                Api$socialcard_Ext.Get_Attr_Val_Dt (p_Scdi_Id     => p_Obj_Id,
                                                    p_Nda_Class   => 'BDT',
                                                    p_Ndc_Id      => 13));
        l_Fn :=
            NVL (
                l_Fn,
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Obj_Id,
                    p_Nda_Class   => 'FN',
                    p_Ndc_Id      => 13));
        l_Ln :=
            NVL (
                l_Ln,
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Obj_Id,
                    p_Nda_Class   => 'LN',
                    p_Ndc_Id      => 13));
        l_Mn :=
            NVL (
                l_Mn,
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Obj_Id,
                    p_Nda_Class   => 'MN',
                    p_Ndc_Id      => 13));


        IF    l_Birth_Dt IS NULL
           OR l_Fn IS NULL
           OR l_Ln IS NULL
           OR (l_Inn IS NULL AND l_Doc_Sn IS NULL)
        THEN
            IF l_Birth_Dt IS NULL
            THEN
                p_Error := p_Error || ' äàòó íàðîäæåííÿ,';
            END IF;

            IF l_Ln IS NULL
            THEN
                p_Error := p_Error || ' ïð³çâèùå,';
            END IF;

            IF l_Fn IS NULL
            THEN
                p_Error := p_Error || ' ³ì’ÿ,';
            END IF;

            IF l_Inn IS NULL AND l_Doc_Sn IS NULL
            THEN
                p_Error := p_Error || ' ÐÍÎÊÏÏ/ïàñïîðò,';
            END IF;

            IF p_Error IS NOT NULL
            THEN
                p_Error :=
                       'Íå âêàçàíî'
                    || RTRIM (p_Error, ',')
                    || '. Ñòâîðåííÿ çàïèòó íåìîæëèâå';
                RETURN NULL;
            END IF;
        END IF;


        Ikis_Rbm.Api$request_Dfs.Reg_Create_Dfs_Rnokpp_Req (
            p_Sc_Id       => NULL,
            p_Plan_Dt     => SYSDATE,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => NULL,
            p_Rn_Src      => 'USS',
            p_Rn_Id       => l_Rn_Id,
            p_Numident    => l_Inn,
            p_Ln          => l_Ln,
            p_Fn          => l_Fn,
            p_Mn          => l_Mn,
            p_Doc_Ser     => NULL,
            p_Doc_Num     => l_Doc_Sn,
            p_Birthday    => l_Birth_Dt,
            p_Wu          => NULL);

        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Api$sc_Verification_Dfs.Reg_Verify_DFS_RNOKPP_Req: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    PROCEDURE Handle_Dfs_Rnokpp_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id           NUMBER;
        l_Scv_Id          NUMBER;
        l_Scdi_Id         NUMBER;
        l_Error_Message   VARCHAR2 (4000);
        l_Hs              NUMBER;
    BEGIN
        l_Hs := Tools.Gethistsession;
        --Îòðèìóºìî ³ä çàïèòó ç îñíîâíîãî æóðíàëó
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ÒÅÕÍ²×ÍÀ ÏÎÌÈËÊÀ(Ï²Ä ×ÀÑ Â²ÄÏÐÀÂÊÈ ÇÀÏÈÒÓ)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Çáåð³ãàºìî â³äïîâ³äü â³ä ÄÏÑ
        Api$sc_Verification.Save_Verification_Answer (
            p_Scva_Rn            => l_Rn_Id,
            p_Scva_Answer_Data   => p_Response,
            p_Scva_Scv           => l_Scv_Id);
        --Îòðèóþºìî ³ä îñîáè
        l_Scdi_Id := Api$sc_Verification.Get_Scv_Obj (l_Scv_Id);

        FOR Rec
            IN (      SELECT *
                        FROM XMLTABLE (
                                 '/*'
                                 PASSING Xmltype (p_Response)
                                 COLUMNS Res          NUMBER PATH 'Result',
                                         Error_Msg    VARCHAR2 (4000) PATH 'Errormsg'))
        LOOP
            IF NVL (Rec.Res, 0) = 0
            THEN
                --ÓÑÏ²ØÍÀ ÂÅÐÈÔ²ÊÀÖ²ß
                Api$sc_Verification.Set_Ok (l_Scv_Id, p_Scvl_Hs => l_Hs);
            ELSE
                --ÂÅÐÈÔ²ÊÀÖ²Þ ÍÅ ÏÐÎÉÄÅÍÎ
                l_Error_Message :=
                       CHR (38)
                    || CASE Rec.Res
                           WHEN 1 THEN '275'
                           WHEN 2 THEN '276'
                           WHEN 3 THEN '277'
                           WHEN 4 THEN '278'
                           WHEN 42 THEN '279'
                           ELSE '107'
                       END;

                IF Api$socialcard_Ext.Get_Scdi_Nrt_Code (l_Scdi_Id) =
                   'USS.PutMozData'
                THEN
                    DECLARE
                        l_Death_Dt   DATE;
                        l_Cert_Num   VARCHAR2 (250);
                        l_Cert_Dt    DATE;
                        l_Code       NUMBER;
                        l_Message    VARCHAR2 (32767);
                    BEGIN
                        l_Code := Api$sc_Verification_Moz.c_Feedback_Verify;
                        l_Message :=
                               'ÄÔÑ. '
                            || REPLACE (
                                   Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                       l_Error_Message),
                                   CHR (10),
                                   ' ');

                        --Ïåðåâ³ðÿºìî ÷è îñîáà ³ç ïðîì³æíèõ äàíèèõ ÿâëÿºòüñÿ ïîìåðëîþ
                        IF Rec.Res = 2
                        THEN
                            Search_Scdi_Death (p_Scdi_Id    => l_Scdi_Id,
                                               p_Death_Dt   => l_Death_Dt,
                                               p_Cert_Num   => l_Cert_Num,
                                               p_Cert_Dt    => l_Cert_Dt);

                            IF l_Death_Dt IS NOT NULL
                            THEN
                                l_Code :=
                                    Api$sc_Verification_Moz.c_Feedback_Dead;
                                l_Message :=
                                       'ÐÍÎÊÏÏ çíÿòî ç îáë³êó (çã³äíî ç äàíèìè ïîäàòêîâî¿) ³ ÄÐÀÖÑ (çã³äíî ç äàíèìè Ì³í`þñò). Çíàéäåíî ÀÇ ïðî ñìåðòü ¹'
                                    || l_Cert_Num
                                    || ' â³ä '
                                    || TO_DATE (l_Cert_Dt, 'dd.mm.yyyy');
                            END IF;
                        END IF;

                        Api$sc_Verification_Moz.Send_Feedback (
                            p_Scdi_Id   => l_Scdi_Id,
                            p_Result    => l_Code,
                            p_Message   => l_Message);
                    END;
                END IF;

                Api$sc_Verification.Set_Not_Verified (
                    l_Scv_Id,
                    p_Scvl_Hs   => l_Hs,
                    p_Error     => l_Error_Message);
            END IF;
        END LOOP;
    END;
END Api$sc_Verification_Dfs;
/