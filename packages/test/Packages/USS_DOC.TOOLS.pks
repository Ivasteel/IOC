/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_DOC.TOOLS
IS
    -- Author  : SHOSTAK
    -- Created : 05.06.2023 11:40:30 PM
    -- Purpose :

    FUNCTION Gethistsession (p_Hs_Wu   Histsession.Hs_Wu%TYPE:= NULL,
                             p_Hs_Cu   Histsession.Hs_Cu%TYPE:= NULL)
        RETURN Histsession.Hs_Id%TYPE;
END Tools;
/


GRANT EXECUTE ON USS_DOC.TOOLS TO OKOMISAROV
/

GRANT EXECUTE ON USS_DOC.TOOLS TO SERVICE_PROXY
/

GRANT EXECUTE ON USS_DOC.TOOLS TO SHOST
/

GRANT EXECUTE ON USS_DOC.TOOLS TO USS_ESR
/

GRANT EXECUTE ON USS_DOC.TOOLS TO USS_PERSON
/

GRANT EXECUTE ON USS_DOC.TOOLS TO USS_RNSP
/

GRANT EXECUTE ON USS_DOC.TOOLS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_DOC.TOOLS
IS
    FUNCTION Gethistsession (p_Hs_Wu   Histsession.Hs_Wu%TYPE:= NULL,
                             p_Hs_Cu   Histsession.Hs_Cu%TYPE:= NULL)
        RETURN Histsession.Hs_Id%TYPE
    IS
        l_Hs   Histsession.Hs_Id%TYPE;
    BEGIN
        INSERT INTO Histsession (Hs_Id,
                                 Hs_Wu,
                                 Hs_Cu,
                                 Hs_Dt)
             VALUES (
                        0,
                        NVL (
                            p_Hs_Wu,
                            Uss_Doc_Context.Get_Context (
                                Uss_Doc_Context.g_Uid)),
                        NVL (
                            p_Hs_Cu,
                            Uss_Doc_Context.Get_Context (
                                Uss_Doc_Context.g_Cuid)),
                        SYSDATE)
          RETURNING Hs_Id
               INTO l_Hs;

        RETURN l_Hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                'TOOLS.GetHistSession: ' || CHR (10) || SQLERRM);
    END;
END Tools;
/