/* Formatted on 8/12/2025 5:46:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_CEA.Dnet$file_Content
IS
    -- Author  : SHOSTAK
    -- Created : 26.05.2021 9:05:07
    -- Purpose :

    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_Fc_Code      IN     File_Content.Fc_Code%TYPE,
                   p_Fc_Content      OUT File_Content.Fc_Content%TYPE,
                   p_Fc_Exists       OUT VARCHAR2);

    -- Зберегти
    PROCEDURE SAVE (p_Fc_Id        IN     File_Content.Fc_Id%TYPE,
                    p_Fc_Content   IN     File_Content.Fc_Content%TYPE,
                    p_Fc_Code      IN     File_Content.Fc_Code%TYPE,
                    p_New_Id          OUT File_Content.Fc_Id%TYPE);
END Dnet$file_Content;
/


GRANT EXECUTE ON USS_CEA.DNET$FILE_CONTENT TO II01RC_USS_CEA_WEB
/

GRANT EXECUTE ON USS_CEA.DNET$FILE_CONTENT TO OKOMISAROV
/

GRANT EXECUTE ON USS_CEA.DNET$FILE_CONTENT TO SERVICE_PROXY
/

GRANT EXECUTE ON USS_CEA.DNET$FILE_CONTENT TO SHOST
/


/* Formatted on 8/12/2025 5:46:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_CEA.Dnet$file_Content
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_Fc_Code      IN     File_Content.Fc_Code%TYPE,
                   p_Fc_Content      OUT File_Content.Fc_Content%TYPE,
                   p_Fc_Exists       OUT VARCHAR2)
    IS
    BEGIN
        SELECT Fc_Content
          INTO p_Fc_Content
          FROM File_Content
         WHERE Fc_Code = p_Fc_Code;

        p_Fc_Exists := 'T';
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_Fc_Exists := 'F';
    END;

    -- Зберегти
    PROCEDURE SAVE (p_Fc_Id        IN     File_Content.Fc_Id%TYPE,
                    p_Fc_Content   IN     File_Content.Fc_Content%TYPE,
                    p_Fc_Code      IN     File_Content.Fc_Code%TYPE,
                    p_New_Id          OUT File_Content.Fc_Id%TYPE)
    IS
    BEGIN
        Api$file_Content.Save (p_Fc_Id        => p_Fc_Id,
                               p_Fc_Content   => p_Fc_Content,
                               p_Fc_Code      => p_Fc_Code,
                               p_New_Id       => p_New_Id);
    END;
END Dnet$file_Content;
/