/* Formatted on 8/12/2025 5:46:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_CEA.Api$file_Content
IS
    -- Зберегти
    PROCEDURE SAVE (p_Fc_Id        IN     File_Content.Fc_Id%TYPE,
                    p_Fc_Content   IN     File_Content.Fc_Content%TYPE,
                    p_Fc_Code      IN     File_Content.Fc_Code%TYPE,
                    p_New_Id          OUT File_Content.Fc_Id%TYPE);

    -- Вилучити
    PROCEDURE DELETE (p_Id File_Content.Fc_Id%TYPE);
END Api$file_Content;
/


GRANT EXECUTE ON USS_CEA.API$FILE_CONTENT TO OKOMISAROV
/

GRANT EXECUTE ON USS_CEA.API$FILE_CONTENT TO SHOST
/


/* Formatted on 8/12/2025 5:46:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_CEA.Api$file_Content
IS
    -- Зберегти
    PROCEDURE SAVE (p_Fc_Id        IN     File_Content.Fc_Id%TYPE,
                    p_Fc_Content   IN     File_Content.Fc_Content%TYPE,
                    p_Fc_Code      IN     File_Content.Fc_Code%TYPE,
                    p_New_Id          OUT File_Content.Fc_Id%TYPE)
    IS
    BEGIN
        INSERT INTO File_Content (Fc_Id, Fc_Content, Fc_Code)
             VALUES (p_Fc_Id, p_Fc_Content, p_Fc_Code)
          RETURNING Fc_Id
               INTO p_New_Id;
    END;

    -- Вилучити
    PROCEDURE DELETE (p_Id File_Content.Fc_Id%TYPE)
    IS
    BEGIN
        DELETE FROM File_Content
              WHERE Fc_Id = p_Id;
    END;
END Api$file_Content;
/