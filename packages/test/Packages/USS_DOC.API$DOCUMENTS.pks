/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_DOC.API$DOCUMENTS
IS
    Package_Name                CONSTANT VARCHAR2 (100) := 'API$DOCUMENTS';

    c_Doc_Actuality_Undefined   CONSTANT VARCHAR2 (10) := 'U';

    --Вложения документа
    TYPE r_Attachment IS RECORD
    (
        File_Code    VARCHAR2 (50),
        Deleted      NUMBER
    );

    TYPE t_Attachments IS TABLE OF r_Attachment;

    PROCEDURE Save_Document (
        p_Doc_Id          IN     Documents.Doc_Id%TYPE,
        p_Doc_Ndt         IN     Documents.Doc_Ndt%TYPE,
        p_Doc_Actuality   IN     Documents.Doc_Actuality%TYPE,
        p_New_Id             OUT Documents.Doc_Id%TYPE);

    PROCEDURE Save_Doc_Hist (
        p_Dh_Id          IN     Doc_Hist.Dh_Id%TYPE,
        p_Dh_Doc         IN     Doc_Hist.Dh_Doc%TYPE,
        p_Dh_Sign_Alg    IN     Doc_Hist.Dh_Sign_Alg%TYPE,
        p_Dh_Ndt         IN     Doc_Hist.Dh_Ndt%TYPE,
        p_Dh_Sign_File   IN     Doc_Hist.Dh_Sign_File%TYPE,
        p_Dh_Actuality   IN     Doc_Hist.Dh_Actuality%TYPE,
        p_Dh_Dt          IN     Doc_Hist.Dh_Dt%TYPE,
        p_Dh_Wu          IN     Doc_Hist.Dh_Wu%TYPE,
        p_Dh_Src         IN     Doc_Hist.Dh_Src%TYPE,
        p_Dh_Cu          IN     Doc_Hist.Dh_Cu%TYPE DEFAULT NULL,
        p_New_Id            OUT Doc_Hist.Dh_Id%TYPE);

    FUNCTION Get_Last_Doc_Hist (p_Dh_Doc Doc_Hist.Dh_Doc%TYPE)
        RETURN Doc_Hist.Dh_Id%TYPE;

    FUNCTION Get_Doc_Hist_Src (p_Dh_Id IN NUMBER)
        RETURN Doc_Hist.Dh_Src%TYPE;

    FUNCTION Generate_File_Code
        RETURN VARCHAR2;

    PROCEDURE Save_File (
        p_File_Id            IN     Files.File_Id%TYPE,
        p_File_Thumb         IN     Files.File_Thumb%TYPE,
        p_File_Code          IN     Files.File_Code%TYPE,
        p_File_Name          IN     Files.File_Name%TYPE,
        p_File_Mime_Type     IN     Files.File_Mime_Type%TYPE,
        p_File_Description   IN     Files.File_Description%TYPE,
        p_File_Create_Dt     IN     Files.File_Create_Dt%TYPE,
        p_File_Wu            IN     Files.File_Wu%TYPE,
        p_File_App           IN     Files.File_App%TYPE,
        p_File_Hash          IN     Files.File_Hash%TYPE,
        p_File_Size          IN     Files.File_Size%TYPE,
        p_File_Cu            IN     Files.File_Cu%TYPE DEFAULT NULL,
        p_New_Id                OUT Files.File_Id%TYPE);

    PROCEDURE Get_File (p_Id IN Files.File_Id%TYPE, p_Res OUT SYS_REFCURSOR);

    FUNCTION File_Is_Attched2doc (p_File_Id IN Files.File_Id%TYPE)
        RETURN BOOLEAN;

    PROCEDURE Delete_File (p_File_Id IN Files.File_Id%TYPE);

    PROCEDURE Save_Attachment (
        p_Dat_Id          IN     Doc_Attachments.Dat_Id%TYPE,
        p_Dat_Num         IN     Doc_Attachments.Dat_Num%TYPE,
        p_Dat_File        IN     Doc_Attachments.Dat_File%TYPE,
        p_Dat_Dh          IN     Doc_Attachments.Dat_Dh%TYPE,
        p_Dat_Sign_File   IN     Doc_Attachments.Dat_Sign_File%TYPE,
        p_Dat_Hs          IN     Doc_Attachments.Dat_Hs%TYPE DEFAULT NULL,
        p_New_Id             OUT Doc_Attachments.Dat_Id%TYPE);

    PROCEDURE Save_Attach_List (p_Doc_Id        NUMBER,
                                p_Dh_Id         NUMBER,
                                p_Attachments   XMLTYPE);

    PROCEDURE Save_Attach_List (p_Doc_Id        NUMBER,
                                p_Dh_Id         NUMBER,
                                p_Attachments   t_Attachments);

    PROCEDURE Set_Attachment_Num (
        p_Dat_Id    IN Doc_Attachments.Dat_Id%TYPE,
        p_Dat_Num   IN Doc_Attachments.Dat_Num%TYPE);

    PROCEDURE Save_Attachment_Sign (
        p_Dats_Dat         IN Doc_Attach_Signs.Dats_Dat%TYPE,
        p_Dats_Sign_File   IN Doc_Attach_Signs.Dats_Sign_File%TYPE,
        p_Dats_Hs          IN Doc_Attach_Signs.Dats_Hs%TYPE DEFAULT NULL);

    PROCEDURE Delete_Attachment (p_Id Doc_Attachments.Dat_Id%TYPE);

    TYPE r_File IS RECORD
    (
        Doc_Id             NUMBER (14),
        File_Code          VARCHAR2 (50),
        File_Name          VARCHAR2 (255),
        File_Mime_Type     VARCHAR2 (255),
        File_Size          NUMBER,
        File_Hash          VARCHAR2 (32),
        File_Create_Dt     DATE,
        File_Decription    VARCHAR2 (255),
        Dh_Id              NUMBER (14),
        Dat_Num            INTEGER
    );

    PROCEDURE Get_Signed_Attachments (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Last_Signed_Attachments (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Attachments (p_Doc_Id            NUMBER,
                               p_Dh_Id             NUMBER,
                               p_Res           OUT SYS_REFCURSOR,
                               p_Params_Mode       INTEGER := 1);

    TYPE r_Attribute IS RECORD
    (
        Doc_Id           NUMBER (14),
        Da_Nda           NUMBER (14),
        Da_Val_String    VARCHAR2 (500),
        Da_Val_Int       INTEGER,
        Da_Val_Dt        DATE,
        Da_Val_Id        NUMBER (14),
        Da_Val_Sum       NUMBER (18, 2),
        Dh_Id            NUMBER (14)
    );

    PROCEDURE Get_Attributes (p_Doc_Id            NUMBER,
                              p_Dh_Id             NUMBER,
                              p_Res           OUT SYS_REFCURSOR,
                              p_Params_Mode       INTEGER := 1);

    PROCEDURE Save_Doc_Attr (p_Dh_Id       IN NUMBER,
                             p_Ndt_Id      IN NUMBER,
                             p_Nda_Class   IN VARCHAR2,
                             p_Val_Str     IN VARCHAR2 DEFAULT NULL,
                             p_Val_Int     IN NUMBER DEFAULT NULL,
                             p_Val_Dt      IN DATE DEFAULT NULL,
                             p_Val_Sum     IN NUMBER DEFAULT NULL,
                             p_Val_Id      IN NUMBER DEFAULT NULL);

    PROCEDURE Save_Doc_Attr (p_Dh_Id     IN NUMBER,
                             p_Nda_Id    IN NUMBER,
                             p_Val_Str   IN VARCHAR2 DEFAULT NULL,
                             p_Val_Int   IN NUMBER DEFAULT NULL,
                             p_Val_Dt    IN DATE DEFAULT NULL,
                             p_Val_Sum   IN NUMBER DEFAULT NULL,
                             p_Val_Id    IN NUMBER DEFAULT NULL);

    PROCEDURE Save_Attribute (
        p_Da_Nda          IN     Doc_Attributes.Da_Nda%TYPE,
        p_Da_Val_String   IN     Doc_Attributes.Da_Val_String%TYPE := NULL,
        p_Da_Val_Int      IN     Doc_Attributes.Da_Val_Int%TYPE := NULL,
        p_Da_Val_Dt       IN     Doc_Attributes.Da_Val_Dt%TYPE := NULL,
        p_Da_Val_Id       IN     Doc_Attributes.Da_Val_Id%TYPE := NULL,
        p_Da_Val_Sum      IN     Doc_Attributes.Da_Val_Sum%TYPE := NULL,
        p_Da_Id              OUT Doc_Attributes.Da_Val_Id%TYPE);

    PROCEDURE Save_Attr_In_Hist (p_Da2h_Da   Doc_Attr2hist.Da2h_Da%TYPE,
                                 p_Da2h_Dh   Doc_Attr2hist.Da2h_Dh%TYPE);

    PROCEDURE Clear_Tmp_Work_Ids;

    FUNCTION Get_Attr_Val_Dt (p_Nda_Class IN VARCHAR2, p_Dh_Id IN NUMBER)
        RETURN DATE;

    FUNCTION Get_Attr_Val_Dt (p_Nda_Id IN NUMBER, p_Dh_Id IN NUMBER)
        RETURN DATE;

    FUNCTION Get_Attr_Val_Str (p_Nda_Class IN VARCHAR2, p_Dh_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Attr_Val_Str (p_Nda_Id IN NUMBER, p_Dh_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Attr_Val_Int (p_Nda_Class IN VARCHAR2, p_Dh_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Attr_Val_Int (p_Nda_Id IN NUMBER, p_Dh_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Attr_Val_Id (p_Nda_Id IN NUMBER, p_Dh_Id IN NUMBER)
        RETURN NUMBER;
END Api$documents;
/


GRANT EXECUTE ON USS_DOC.API$DOCUMENTS TO II01RC_USS_DOC_INTERNAL
/

GRANT EXECUTE ON USS_DOC.API$DOCUMENTS TO IKIS_RBM
/

GRANT EXECUTE ON USS_DOC.API$DOCUMENTS TO OKOMISAROV
/

GRANT EXECUTE ON USS_DOC.API$DOCUMENTS TO SHOST
/

GRANT EXECUTE ON USS_DOC.API$DOCUMENTS TO USS_ESR
/

GRANT EXECUTE ON USS_DOC.API$DOCUMENTS TO USS_PERSON
/

GRANT EXECUTE ON USS_DOC.API$DOCUMENTS TO USS_RNSP
/

GRANT EXECUTE ON USS_DOC.API$DOCUMENTS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_DOC.API$DOCUMENTS
IS
    --=========================================================================
    --                        ДОКУМЕНТЫ И СРЕЗЫ
    --=========================================================================
    PROCEDURE Save_Document (
        p_Doc_Id          IN     Documents.Doc_Id%TYPE,
        p_Doc_Ndt         IN     Documents.Doc_Ndt%TYPE,
        p_Doc_Actuality   IN     Documents.Doc_Actuality%TYPE,
        p_New_Id             OUT Documents.Doc_Id%TYPE)
    IS
    BEGIN
        IF p_Doc_Id IS NULL
        THEN
            INSERT INTO Documents (Doc_Ndt, Doc_Actuality)
                 VALUES (p_Doc_Ndt, p_Doc_Actuality)
              RETURNING Doc_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Doc_Id;

            UPDATE Documents
               SET Doc_Ndt = p_Doc_Ndt, Doc_Actuality = p_Doc_Actuality
             WHERE Doc_Id = p_Doc_Id;
        END IF;
    END;

    PROCEDURE Save_Doc_Hist (
        p_Dh_Id          IN     Doc_Hist.Dh_Id%TYPE,
        p_Dh_Doc         IN     Doc_Hist.Dh_Doc%TYPE,
        p_Dh_Sign_Alg    IN     Doc_Hist.Dh_Sign_Alg%TYPE,
        p_Dh_Ndt         IN     Doc_Hist.Dh_Ndt%TYPE,
        p_Dh_Sign_File   IN     Doc_Hist.Dh_Sign_File%TYPE,
        p_Dh_Actuality   IN     Doc_Hist.Dh_Actuality%TYPE,
        p_Dh_Dt          IN     Doc_Hist.Dh_Dt%TYPE,
        p_Dh_Wu          IN     Doc_Hist.Dh_Wu%TYPE,
        p_Dh_Src         IN     Doc_Hist.Dh_Src%TYPE,
        p_Dh_Cu          IN     Doc_Hist.Dh_Cu%TYPE DEFAULT NULL,
        p_New_Id            OUT Doc_Hist.Dh_Id%TYPE)
    IS
    BEGIN
        IF p_Dh_Id IS NULL
        THEN
            INSERT INTO Doc_Hist (Dh_Doc,
                                  Dh_Sign_Alg,
                                  Dh_Ndt,
                                  Dh_Sign_File,
                                  Dh_Actuality,
                                  Dh_Dt,
                                  Dh_Wu,
                                  Dh_Src,
                                  Dh_Cu)
                 VALUES (p_Dh_Doc,
                         p_Dh_Sign_Alg,
                         p_Dh_Ndt,
                         p_Dh_Sign_File,
                         p_Dh_Actuality,
                         p_Dh_Dt,
                         p_Dh_Wu,
                         p_Dh_Src,
                         p_Dh_Cu)
              RETURNING Dh_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Dh_Id;

            UPDATE Doc_Hist
               SET                                  --Dh_Doc       = p_Dh_Doc,
                   Dh_Sign_Alg = p_Dh_Sign_Alg,
                   Dh_Ndt = p_Dh_Ndt,
                   Dh_Sign_File = p_Dh_Sign_File,
                   Dh_Actuality = p_Dh_Actuality,
                   Dh_Dt = p_Dh_Dt,
                   Dh_Wu = p_Dh_Wu,
                   Dh_Src = p_Dh_Src,
                   Dh_Cu = p_Dh_Cu
             WHERE Dh_Id = p_Dh_Id;
        END IF;
    END;

    FUNCTION Get_Last_Doc_Hist (p_Dh_Doc Doc_Hist.Dh_Doc%TYPE)
        RETURN Doc_Hist.Dh_Id%TYPE
    IS
        l_Result   Doc_Hist.Dh_Id%TYPE;
    BEGIN
        SELECT MAX (Dh_Id)
          INTO l_Result
          FROM (  SELECT h.Dh_Id
                    FROM Doc_Hist h
                   WHERE h.Dh_Doc = p_Dh_Doc
                ORDER BY h.Dh_Dt DESC
                   FETCH FIRST ROW ONLY);

        RETURN l_Result;
    END;

    FUNCTION Get_Doc_Hist_Src (p_Dh_Id IN NUMBER)
        RETURN Doc_Hist.Dh_Src%TYPE
    IS
        l_Result   Doc_Hist.Dh_Src%TYPE;
    BEGIN
        SELECT h.Dh_Src
          INTO l_Result
          FROM Doc_Hist h
         WHERE h.Dh_Id = p_Dh_Id;

        RETURN l_Result;
    END;

    --=========================================================================
    --                        ФАЙЛЫ И ВЛОЖЕНИЯ
    --=========================================================================
    ------------------------------------------------------------------
    --Генерация кода файла
    ------------------------------------------------------------------
    FUNCTION Generate_File_Code
        RETURN VARCHAR2
    IS
    BEGIN
        DBMS_RANDOM.Seed (
               TO_CHAR (SYSTIMESTAMP, 'ddmmyyyyhh24missffff')
            || SYS_CONTEXT ('USERENV', 'SID'));
        RETURN LOWER (DBMS_RANDOM.String (Opt => 'x', Len => 12));
    END;

    PROCEDURE Save_File (
        p_File_Id            IN     Files.File_Id%TYPE,
        p_File_Thumb         IN     Files.File_Thumb%TYPE,
        p_File_Code          IN     Files.File_Code%TYPE,
        p_File_Name          IN     Files.File_Name%TYPE,
        p_File_Mime_Type     IN     Files.File_Mime_Type%TYPE,
        p_File_Description   IN     Files.File_Description%TYPE,
        p_File_Create_Dt     IN     Files.File_Create_Dt%TYPE,
        p_File_Wu            IN     Files.File_Wu%TYPE,
        p_File_App           IN     Files.File_App%TYPE,
        p_File_Hash          IN     Files.File_Hash%TYPE,
        p_File_Size          IN     Files.File_Size%TYPE,
        p_File_Cu            IN     Files.File_Cu%TYPE DEFAULT NULL,
        p_New_Id                OUT Files.File_Id%TYPE)
    IS
    BEGIN
        IF p_File_Id IS NULL
        THEN
            INSERT INTO Files (File_Thumb,
                               File_Code,
                               File_Name,
                               File_Mime_Type,
                               File_Description,
                               File_Create_Dt,
                               File_Wu,
                               File_App,
                               File_Hash,
                               File_Size,
                               File_Cu)
                 VALUES (p_File_Thumb,
                         p_File_Code,
                         p_File_Name,
                         p_File_Mime_Type,
                         p_File_Description,
                         p_File_Create_Dt,
                         p_File_Wu,
                         p_File_App,
                         p_File_Hash,
                         p_File_Size,
                         p_File_Cu)
              RETURNING File_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_File_Id;

            UPDATE Files
               SET File_Thumb = p_File_Thumb,
                   File_Code = p_File_Code,
                   File_Name = p_File_Name,
                   File_Mime_Type = p_File_Mime_Type,
                   File_Description = p_File_Description,
                   File_Create_Dt = p_File_Create_Dt,
                   File_Wu = p_File_Wu,
                   File_App = p_File_App,
                   File_Hash = p_File_Hash,
                   File_Size = p_File_Size
             WHERE File_Id = p_File_Id;
        END IF;
    END;

    PROCEDURE Get_File (p_Id IN Files.File_Id%TYPE, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR SELECT File_Id,
                              -- FILES
                              File_Thumb,
                              File_Code,
                              File_Name,
                              File_Mime_Type,
                              File_Description,
                              File_Create_Dt,
                              File_Wu,
                              -- API_APPLICATIONS
                              File_App,
                              File_Hash,
                              File_Size
                         FROM Files
                        WHERE File_Id = p_Id;
    END;

    PROCEDURE Delete_File (p_File_Id IN Files.File_Id%TYPE)
    IS
    BEGIN
        DELETE FROM Files f
              WHERE f.File_Id = p_File_Id;
    END;

    FUNCTION File_Is_Attched2doc (p_File_Id IN Files.File_Id%TYPE)
        RETURN BOOLEAN
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Result
          FROM Doc_Attachments a
         WHERE a.Dat_File = p_File_Id;

        RETURN l_Result = 1;
    END;

    PROCEDURE Save_Attachment (
        p_Dat_Id          IN     Doc_Attachments.Dat_Id%TYPE,
        p_Dat_Num         IN     Doc_Attachments.Dat_Num%TYPE,
        p_Dat_File        IN     Doc_Attachments.Dat_File%TYPE,
        p_Dat_Dh          IN     Doc_Attachments.Dat_Dh%TYPE,
        p_Dat_Sign_File   IN     Doc_Attachments.Dat_Sign_File%TYPE,
        p_Dat_Hs          IN     Doc_Attachments.Dat_Hs%TYPE DEFAULT NULL,
        p_New_Id             OUT Doc_Attachments.Dat_Id%TYPE)
    IS
        l_Cnt      INTEGER;
        l_New_Id   Doc_Attachments.Dat_Id%TYPE;
    BEGIN
        SELECT COUNT (*), MIN (Dat_Id)
          INTO l_Cnt, l_New_Id
          FROM Doc_Attachments
         WHERE Dat_Dh = p_Dat_Dh AND Dat_File = p_Dat_File;

        IF l_Cnt > 0
        THEN
            p_New_Id := l_New_Id;

            UPDATE Doc_Attachments
               SET Dat_Num = p_Dat_Num,
                   Dat_Sign_File = NVL (p_Dat_Sign_File, Dat_Sign_File),
                   Dat_Hs = p_Dat_Hs
             WHERE Dat_File = p_Dat_File AND Dat_Dh = p_Dat_Dh;
        ELSE
            INSERT INTO Doc_Attachments (Dat_Num,
                                         Dat_File,
                                         Dat_Dh,
                                         Dat_Sign_File,
                                         Dat_Hs)
                 VALUES (p_Dat_Num,
                         p_Dat_File,
                         p_Dat_Dh,
                         p_Dat_Sign_File,
                         p_Dat_Hs)
              RETURNING Dat_Id
                   INTO p_New_Id;
        END IF;
    /*
    IF p_Dat_Id IS NULL
    THEN
     INSERT INTO Doc_Attachments
      (Dat_Num,
       Dat_File,
       Dat_Dh,
       Dat_Sign_File)
     VALUES
      (p_Dat_Num,
       p_Dat_File,
       p_Dat_Dh,
       p_Dat_Sign_File)
     RETURNING Dat_Id INTO p_New_Id;
    ELSE
     p_New_Id := p_Dat_Id;

     UPDATE Doc_Attachments
        SET Dat_Num       = p_Dat_Num,
            Dat_File      = p_Dat_File,
            Dat_Dh        = p_Dat_Dh,
            Dat_Sign_File = p_Dat_Sign_File
      WHERE Dat_Id = p_Dat_Id;
    END IF;
    */
    END;

    PROCEDURE Save_Attach_List (p_Doc_Id        NUMBER,
                                p_Dh_Id         NUMBER,
                                p_Attachments   XMLTYPE)
    IS
        l_Attachments   t_Attachments;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Attachments',
                                         FALSE,
                                         FALSE)
            BULK COLLECT INTO l_Attachments
            USING p_Attachments;

        Save_Attach_List (p_Doc_Id        => p_Doc_Id,
                          p_Dh_Id         => p_Dh_Id,
                          p_Attachments   => l_Attachments);
    END;

    PROCEDURE Save_Attach_List (p_Doc_Id        NUMBER,
                                p_Dh_Id         NUMBER,
                                p_Attachments   t_Attachments)
    IS
        l_Dh_Id   NUMBER;
    BEGIN
        --Если срез не указан явно, получаем последний срез документа по дате создания
        l_Dh_Id :=
            NVL (p_Dh_Id,
                 Api$documents.Get_Last_Doc_Hist (p_Dh_Doc => p_Doc_Id));

        FOR Rec
            IN (WITH
                    Actual_Attachs
                    AS
                        (SELECT x.*, ROWNUM AS Dat_Num
                           FROM TABLE (p_Attachments) x)
                SELECT a.Dat_Id, Aa.*
                  FROM Doc_Attachments  a
                       JOIN Files f ON a.Dat_File = f.File_Id
                       JOIN Actual_Attachs Aa ON f.File_Code = Aa.File_Code
                 WHERE a.Dat_Dh = l_Dh_Id)
        LOOP
            IF Rec.Deleted = 1
            THEN
                Delete_Attachment (p_Id => Rec.Dat_Id);
            ELSE
                Set_Attachment_Num (p_Dat_Id    => Rec.Dat_Id,
                                    p_Dat_Num   => Rec.Dat_Num);
            END IF;
        END LOOP;
    END;

    PROCEDURE Set_Attachment_Num (
        p_Dat_Id    IN Doc_Attachments.Dat_Id%TYPE,
        p_Dat_Num   IN Doc_Attachments.Dat_Num%TYPE)
    IS
    BEGIN
        UPDATE Doc_Attachments a
           SET a.Dat_Num = p_Dat_Num
         WHERE a.Dat_Id = p_Dat_Id AND NVL (a.Dat_Num, -1) <> p_Dat_Num;
    END;

    PROCEDURE Save_Attachment_Sign (
        p_Dats_Dat         IN Doc_Attach_Signs.Dats_Dat%TYPE,
        p_Dats_Sign_File   IN Doc_Attach_Signs.Dats_Sign_File%TYPE,
        p_Dats_Hs          IN Doc_Attach_Signs.Dats_Hs%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Doc_Attach_Signs (Dats_Id,
                                      Dats_Dat,
                                      Dats_Sign_File,
                                      Dats_Hs)
             VALUES (0,
                     p_Dats_Dat,
                     p_Dats_Sign_File,
                     p_Dats_Hs);
    END;

    PROCEDURE Delete_Attachment (p_Id Doc_Attachments.Dat_Id%TYPE)
    IS
    BEGIN
        DELETE FROM Doc_Attachments
              WHERE Dat_Id = p_Id;
    END;

    PROCEDURE Save_Doc_Attr (p_Dh_Id       IN NUMBER,
                             p_Ndt_Id      IN NUMBER,
                             p_Nda_Class   IN VARCHAR2,
                             p_Val_Str     IN VARCHAR2 DEFAULT NULL,
                             p_Val_Int     IN NUMBER DEFAULT NULL,
                             p_Val_Dt      IN DATE DEFAULT NULL,
                             p_Val_Sum     IN NUMBER DEFAULT NULL,
                             p_Val_Id      IN NUMBER DEFAULT NULL)
    IS
        l_Nda_Id   NUMBER;
    BEGIN
        SELECT n.Nda_Id
          INTO l_Nda_Id
          FROM Uss_Ndi.v_Ndi_Document_Attr n
         WHERE n.Nda_Ndt = p_Ndt_Id AND n.Nda_Class = p_Nda_Class;

        Save_Doc_Attr (p_Dh_Id     => p_Dh_Id,
                       p_Nda_Id    => l_Nda_Id,
                       p_Val_Str   => p_Val_Str,
                       p_Val_Int   => p_Val_Int,
                       p_Val_Dt    => p_Val_Dt,
                       p_Val_Sum   => p_Val_Sum,
                       p_Val_Id    => p_Val_Id);
    END;

    PROCEDURE Save_Doc_Attr (p_Dh_Id     IN NUMBER,
                             p_Nda_Id    IN NUMBER,
                             p_Val_Str   IN VARCHAR2 DEFAULT NULL,
                             p_Val_Int   IN NUMBER DEFAULT NULL,
                             p_Val_Dt    IN DATE DEFAULT NULL,
                             p_Val_Sum   IN NUMBER DEFAULT NULL,
                             p_Val_Id    IN NUMBER DEFAULT NULL)
    IS
        l_Da_Id   NUMBER;
    BEGIN
        Save_Attribute (p_Da_Nda          => p_Nda_Id,
                        p_Da_Val_String   => p_Val_Str,
                        p_Da_Val_Int      => p_Val_Int,
                        p_Da_Val_Dt       => p_Val_Dt,
                        p_Da_Val_Sum      => p_Val_Sum,
                        p_Da_Val_Id       => p_Val_Id,
                        p_Da_Id           => l_Da_Id);
        Save_Attr_In_Hist (p_Da2h_Da => l_Da_Id, p_Da2h_Dh => p_Dh_Id);
    END;

    --=========================================================================
    --                        АТРИБУТЫ
    --=========================================================================
    PROCEDURE Save_Attribute (
        p_Da_Nda          IN     Doc_Attributes.Da_Nda%TYPE,
        p_Da_Val_String   IN     Doc_Attributes.Da_Val_String%TYPE := NULL,
        p_Da_Val_Int      IN     Doc_Attributes.Da_Val_Int%TYPE := NULL,
        p_Da_Val_Dt       IN     Doc_Attributes.Da_Val_Dt%TYPE := NULL,
        p_Da_Val_Id       IN     Doc_Attributes.Da_Val_Id%TYPE := NULL,
        p_Da_Val_Sum      IN     Doc_Attributes.Da_Val_Sum%TYPE := NULL,
        p_Da_Id              OUT Doc_Attributes.Da_Val_Id%TYPE)
    IS
        l_Da_Id   Doc_Attributes.Da_Id%TYPE;
    BEGIN
        --Пошук вже існуючого вектору атрибутів серед бібліотеки атрибутів за типом атрибуту документу
        --Наявна схема бази, в якій в таблиця doc_attributes є довідником, а не деталізацією таблици document,
        --потребує пошуку рядка в довіднику, аби не роздувати довідник дублікатами.
        --В майбутньому, коли даний запит гарантовано стане повільним (бо буде відпрацьовувати FULL SCAN),
        --його потрібно буде розділити на декілька запитів, які будуть шукати записи в залежності від
        --наданих не пустих параметрів (а "у загальному" можливо одночасне заповнення декількох значень в одному
        --атрибуті) за індексованими парами "da_nda+da_val_string" або "da_nda+da_val_dt" тощо з відповідними
        --хінтами оптимізатора.
        /*SELECT MIN(Da_Id)
         INTO l_Da_Id
         FROM Doc_Attributes
        WHERE Da_Nda = p_Da_Nda
              AND (Da_Val_String = p_Da_Val_String OR (p_Da_Val_String IS NULL AND Da_Val_String IS NULL))
              AND (Da_Val_Int = p_Da_Val_Int OR (p_Da_Val_Int IS NULL AND Da_Val_Int IS NULL))
              AND (Da_Val_Dt = p_Da_Val_Dt OR (p_Da_Val_Dt IS NULL AND Da_Val_Dt IS NULL))
              AND (Da_Val_Id = p_Da_Val_Id OR (p_Da_Val_Id IS NULL AND Da_Val_Id IS NULL))
              AND (Da_Val_Sum = p_Da_Val_Sum OR (p_Da_Val_Sum IS NULL AND Da_Val_Sum IS NULL));*/

        --shost 2021.11.19
        IF p_Da_Val_Id IS NOT NULL
        THEN
            SELECT MIN (Da_Id)
              INTO l_Da_Id
              FROM Doc_Attributes a
             WHERE a.Da_Nda = p_Da_Nda AND (a.Da_Val_Id = p_Da_Val_Id);
        ELSIF p_Da_Val_String IS NOT NULL
        THEN
            SELECT MIN (Da_Id)
              INTO l_Da_Id
              FROM Doc_Attributes a
             WHERE     a.Da_Nda = p_Da_Nda
                   AND (a.Da_Val_String = p_Da_Val_String);
        ELSIF p_Da_Val_Int IS NOT NULL
        THEN
            SELECT MIN (Da_Id)
              INTO l_Da_Id
              FROM Doc_Attributes a
             WHERE a.Da_Nda = p_Da_Nda AND (a.Da_Val_Int = p_Da_Val_Int);
        ELSIF p_Da_Val_Dt IS NOT NULL
        THEN
            SELECT MIN (Da_Id)
              INTO l_Da_Id
              FROM Doc_Attributes a
             WHERE a.Da_Nda = p_Da_Nda AND (a.Da_Val_Dt = p_Da_Val_Dt);
        ELSIF p_Da_Val_Sum IS NOT NULL
        THEN
            SELECT MIN (Da_Id)
              INTO l_Da_Id
              FROM Doc_Attributes a
             WHERE a.Da_Nda = p_Da_Nda AND (a.Da_Val_Sum = p_Da_Val_Sum);
        ELSE
            --Порожнє значання
            SELECT MIN (Da_Id)
              INTO l_Da_Id
              FROM Doc_Attributes a
             WHERE     a.Da_Nda = p_Da_Nda
                   AND (    a.Da_Val_String IS NULL
                        AND a.Da_Val_Dt IS NULL
                        AND a.Da_Val_Sum IS NULL
                        AND a.Da_Val_Int IS NULL
                        AND a.Da_Val_Id IS NULL);
        END IF;

        IF l_Da_Id IS NULL
        THEN
            INSERT INTO Doc_Attributes (Da_Id,
                                        Da_Nda,
                                        Da_Val_String,
                                        Da_Val_Int,
                                        Da_Val_Dt,
                                        Da_Val_Sum,
                                        Da_Val_Id)
                 VALUES (0,
                         p_Da_Nda,
                         p_Da_Val_String,
                         p_Da_Val_Int,
                         p_Da_Val_Dt,
                         p_Da_Val_Sum,
                         p_Da_Val_Id)
              RETURNING Da_Id
                   INTO l_Da_Id;
        END IF;

        p_Da_Id := l_Da_Id;
    END;

    PROCEDURE Save_Attr_In_Hist (p_Da2h_Da   Doc_Attr2hist.Da2h_Da%TYPE,
                                 p_Da2h_Dh   Doc_Attr2hist.Da2h_Dh%TYPE)
    IS
    BEGIN
        MERGE INTO Doc_Attr2hist
             USING (SELECT p_Da2h_Da AS x_Da2h_Da, p_Da2h_Dh AS x_Da2h_Dh
                      FROM DUAL)
                ON (Da2h_Da = x_Da2h_Da AND Da2h_Dh = x_Da2h_Dh)
        WHEN NOT MATCHED
        THEN
            INSERT     (Da2h_Id, Da2h_Da, Da2h_Dh)
                VALUES (0, x_Da2h_Da, x_Da2h_Dh);
    END;

    PROCEDURE Clear_Tmp_Work_Ids
    IS
    BEGIN
        DELETE FROM Tmp_Work_Ids
              WHERE 1 = 1;

        DELETE FROM Tmp_Work_Set1
              WHERE 1 = 1;
    END;

    PROCEDURE Get_Signed_Attachments (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        DELETE FROM Tmp_Work_Set1
              WHERE 1 = 1;

        --За декількома ід-ами документів (через tmp_work_set1, зрізи відомі)
        INSERT INTO Tmp_Work_Set1 (x_Id1, x_Id2)
            SELECT h.Dh_Doc, h.Dh_Id
              FROM Tmp_Work_Ids JOIN Doc_Hist h ON x_Id = h.Dh_Id;

        OPEN p_Res FOR
              SELECT /*+index(t I_TWS_SET1) index(a IFK_DAT_DH)*/
                     x_Id1                              AS Doc_Id,
                     f.File_Code,
                     f.File_Name,
                     f.File_Mime_Type,
                     f.File_Size,
                     f.File_Hash,
                     f.File_Create_Dt,
                     f.File_Description,
                     s.File_Code                        AS File_Sign_Code,
                     s.File_Hash                        AS File_Sign_Hash,
                     (SELECT LISTAGG (Fs.File_Code, ',')
                                 WITHIN GROUP (ORDER BY Ss.Dats_Id)
                        FROM Doc_Attach_Signs Ss
                             JOIN Files Fs
                                 ON Ss.Dats_Sign_File = Fs.File_Id
                       WHERE Ss.Dats_Dat = a.Dat_Id)    AS Added_Signs,
                     a.Dat_Num,
                     Dat_Dh                             AS Dh_Id
                FROM Doc_Attachments a,
                     Files          f,
                     Files          s,
                     Tmp_Work_Set1  t
               WHERE     a.Dat_Dh = x_Id2
                     AND a.Dat_File = f.File_Id
                     AND a.Dat_Sign_File = s.File_Id(+)
            ORDER BY a.Dat_Num;
    END;

    PROCEDURE Get_Last_Signed_Attachments (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        DELETE FROM Tmp_Work_Set1
              WHERE 1 = 1;

        --За декількома ід-ами документів (через tmp_work_set1, зрізи відомі)
        INSERT INTO Tmp_Work_Set1 (x_Id1, x_Id2)
            SELECT h.Dh_Doc, h.Dh_Id
              FROM Tmp_Work_Ids JOIN Doc_Hist h ON x_Id = h.Dh_Id;

        OPEN p_Res FOR
              SELECT /*+index(t I_TWS_SET1) index(a IFK_DAT_DH)*/
                     Doc_Id,
                     File_Code,
                     File_Name,
                     File_Mime_Type,
                     File_Size,
                     File_Hash,
                     File_Create_Dt,
                     File_Description,
                     File_Sign_Code,
                     File_Sign_Hash,
                     (SELECT LISTAGG (Fs.File_Code, ',')
                                 WITHIN GROUP (ORDER BY Ss.Dats_Id)
                        FROM Doc_Attach_Signs Ss
                             JOIN Files Fs
                                 ON Ss.Dats_Sign_File = Fs.File_Id
                       WHERE Ss.Dats_Dat = Dat_Id)    AS Added_Signs,
                     Dat_Num,
                     Dh_Id
                FROM (SELECT x_Id1                  AS Doc_Id,
                             f.File_Code,
                             f.File_Name,
                             f.File_Mime_Type,
                             f.File_Size,
                             f.File_Hash,
                             f.File_Create_Dt,
                             f.File_Description,
                             s.File_Code            AS File_Sign_Code,
                             s.File_Hash            AS File_Sign_Hash,
                             a.Dat_Id               AS Added_Signs,
                             a.dat_id,
                             NVL (a.Dat_Num, -1)    Dat_Num,
                             Dat_Dh                 AS Dh_Id,
                             NVL (MAX (a.Dat_Num) OVER (PARTITION BY x_Id1),
                                  -1)               Max_Dat_Num
                        FROM Doc_Attachments a,
                             Files          f,
                             Files          s,
                             Tmp_Work_Set1  t
                       WHERE     a.Dat_Dh = x_Id2
                             AND a.Dat_File = f.File_Id
                             AND a.Dat_Sign_File = s.File_Id(+))
               WHERE Dat_Num = Max_Dat_Num
            ORDER BY Dat_Num;
    END;


    PROCEDURE Get_Attachments (p_Doc_Id            NUMBER,
                               p_Dh_Id             NUMBER,
                               p_Res           OUT SYS_REFCURSOR,
                               p_Params_Mode       INTEGER := 1)
    IS
        l_Dh_Id         NUMBER;
        l_Params_Mode   INTEGER := NVL (p_Params_Mode, 1);
    BEGIN
        --Если срез не указан явно, получаем последний срез документа по дате создания
        --  l_dh_id := NVL(p_Dh_Id, API$DOCUMENTS.Get_Last_Doc_Hist(p_dh_doc => p_doc_id));

        IF l_Params_Mode = 1
        THEN
            --За 1 ід-ом документа
            DELETE FROM Tmp_Work_Set1
                  WHERE 1 = 1;

            INSERT INTO Tmp_Work_Set1 (x_Id1, x_Id2)
                 VALUES (p_Doc_Id, p_Dh_Id);
        ELSIF l_Params_Mode = 2
        THEN
            --За декількома ід-ами документів (через tmp_work_ids, тобто без зрізу)
            DELETE FROM Tmp_Work_Set1
                  WHERE 1 = 1;

            INSERT INTO Tmp_Work_Set1 (x_Id1)
                SELECT x_Id FROM Tmp_Work_Ids;
        ELSIF l_Params_Mode = 3
        THEN
            DELETE FROM Tmp_Work_Set1
                  WHERE 1 = 1;

            --За декількома ід-ами документів (через tmp_work_set1, зрізи відомі)
            INSERT INTO Tmp_Work_Set1 (x_Id1, x_Id2)
                SELECT h.Dh_Doc, h.Dh_Id
                  FROM Tmp_Work_Ids JOIN Doc_Hist h ON x_Id = h.Dh_Id;
        END IF;

        --Якщо не передали зріз - обраховуємо
        UPDATE Tmp_Work_Set1
           SET x_Id2 = Api$documents.Get_Last_Doc_Hist (p_Dh_Doc => x_Id1)
         WHERE x_Id2 IS NULL;

        OPEN p_Res FOR   SELECT /*+index(t I_TWS_SET1) index(a IFK_DAT_DH)*/
                                x_Id1      AS Doc_Id,
                                File_Code,
                                File_Name,
                                File_Mime_Type,
                                File_Size,
                                File_Hash,
                                File_Create_Dt,
                                File_Description,
                                Dat_Dh     AS Dh_Id,
                                Dat_Num
                           FROM Doc_Attachments a, Files f, Tmp_Work_Set1 t
                          WHERE a.Dat_Dh = x_Id2 AND a.Dat_File = f.File_Id
                       ORDER BY a.Dat_Num;
    END;

    PROCEDURE Get_Attributes (p_Doc_Id            NUMBER,
                              p_Dh_Id             NUMBER,
                              p_Res           OUT SYS_REFCURSOR,
                              p_Params_Mode       INTEGER := 1)
    IS
        l_Dh_Id         NUMBER;
        l_Params_Mode   INTEGER := NVL (p_Params_Mode, 1);
    BEGIN
        --Если срез не указан явно, получаем последний срез документа по дате создания
        --l_dh_id := NVL(p_dh_id, API$DOCUMENTS.Get_Last_Doc_Hist(p_Dh_Doc => p_Doc_Id));

        IF l_Params_Mode = 1
        THEN
            --За 1 ід-ом документа
            DELETE FROM Tmp_Work_Set1
                  WHERE 1 = 1;

            INSERT INTO Tmp_Work_Set1 (x_Id1, x_Id2)
                 VALUES (p_Doc_Id, p_Dh_Id);
        ELSIF l_Params_Mode = 2
        THEN
            --За декількома ід-ами документів (через tmp_work_ids, тобто без зрізу)
            DELETE FROM Tmp_Work_Set1
                  WHERE 1 = 1;

            INSERT INTO Tmp_Work_Set1 (x_Id1)
                SELECT x_Id FROM Tmp_Work_Ids;
        ELSIF l_Params_Mode = 3
        THEN
            DELETE FROM Tmp_Work_Set1
                  WHERE 1 = 1;

            --За декількома ід-ами документів (через tmp_work_set1, зрізи відомі)
            INSERT INTO Tmp_Work_Set1 (x_Id1, x_Id2)
                SELECT h.Dh_Doc, h.Dh_Id
                  FROM Tmp_Work_Ids JOIN Doc_Hist h ON x_Id = h.Dh_Id;
        END IF;

        --Якщо не передали зріз - обраховуємо
        UPDATE Tmp_Work_Set1
           SET x_Id2 = Api$documents.Get_Last_Doc_Hist (p_Dh_Doc => x_Id1)
         WHERE x_Id2 IS NULL;

        OPEN p_Res FOR
              SELECT /*+index(t I_TWS_SET1) index(h IFK_DA2H_DH)*/
                     x_Id1             AS Doc_Id,
                     Da_Nda            AS Apda_Nda,
                     Da_Val_String     AS Apda_Val_String,
                     Da_Val_Int        AS Apda_Val_Int,
                     Da_Val_Dt         AS Apda_Val_Dt,
                     Da_Val_Id         AS Apda_Val_Id,
                     Da_Val_Sum        AS Apda_Val_Sum,
                     Da2h_Dh           AS Dh_Id
                FROM Doc_Attr2hist              h,
                     Doc_Attributes,
                     Tmp_Work_Set1              t,
                     Uss_Ndi.v_Ndi_Document_Attr n
               WHERE Da2h_Dh = x_Id2 AND Da2h_Da = Da_Id AND Da_Nda = n.Nda_Id
            ORDER BY n.Nda_Order;
    END;

    FUNCTION Get_Attr_Val_Dt (p_Nda_Class IN VARCHAR2, p_Dh_Id IN NUMBER)
        RETURN DATE
    IS
        l_Val   DATE;
    BEGIN
        SELECT MAX (a.Da_Val_Dt)
          INTO l_Val
          FROM Uss_Doc.Doc_Attr2hist  h
               JOIN Uss_Doc.Doc_Attributes a ON h.Da2h_Da = a.Da_Id
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Da_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE h.Da2h_Dh = p_Dh_Id;

        RETURN l_Val;
    END;

    FUNCTION Get_Attr_Val_Dt (p_Nda_Id IN NUMBER, p_Dh_Id IN NUMBER)
        RETURN DATE
    IS
        l_Val   DATE;
    BEGIN
        SELECT MAX (a.Da_Val_Dt)
          INTO l_Val
          FROM Uss_Doc.Doc_Attr2hist  h
               JOIN Uss_Doc.Doc_Attributes a
                   ON h.Da2h_Da = a.Da_Id AND a.Da_Nda = p_Nda_Id
         WHERE h.Da2h_Dh = p_Dh_Id;

        RETURN l_Val;
    END;

    FUNCTION Get_Attr_Val_Str (p_Nda_Class IN VARCHAR2, p_Dh_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Val   Uss_Doc.Doc_Attributes.Da_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Da_Val_String)
          INTO l_Val
          FROM Uss_Doc.Doc_Attr2hist  h
               JOIN Uss_Doc.Doc_Attributes a ON h.Da2h_Da = a.Da_Id
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Da_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE h.Da2h_Dh = p_Dh_Id;

        RETURN l_Val;
    END;

    FUNCTION Get_Attr_Val_Str (p_Nda_Id IN NUMBER, p_Dh_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Val   Uss_Doc.Doc_Attributes.Da_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Da_Val_String)
          INTO l_Val
          FROM Uss_Doc.Doc_Attr2hist  h
               JOIN Uss_Doc.Doc_Attributes a
                   ON h.Da2h_Da = a.Da_Id AND a.Da_Nda = p_Nda_Id
         WHERE h.Da2h_Dh = p_Dh_Id;

        RETURN l_Val;
    END;

    FUNCTION Get_Attr_Val_Int (p_Nda_Class IN VARCHAR2, p_Dh_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Val   Uss_Doc.Doc_Attributes.Da_Val_Int%TYPE;
    BEGIN
        SELECT MAX (a.Da_Val_Int)
          INTO l_Val
          FROM Uss_Doc.Doc_Attr2hist  h
               JOIN Uss_Doc.Doc_Attributes a ON h.Da2h_Da = a.Da_Id
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Da_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE h.Da2h_Dh = p_Dh_Id;

        RETURN l_Val;
    END;

    FUNCTION Get_Attr_Val_Int (p_Nda_Id IN NUMBER, p_Dh_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Val   Uss_Doc.Doc_Attributes.Da_Val_Int%TYPE;
    BEGIN
        SELECT MAX (a.Da_Val_Int)
          INTO l_Val
          FROM Uss_Doc.Doc_Attr2hist  h
               JOIN Uss_Doc.Doc_Attributes a
                   ON h.Da2h_Da = a.Da_Id AND a.Da_Nda = p_Nda_Id
         WHERE h.Da2h_Dh = p_Dh_Id;

        RETURN l_Val;
    END;

    FUNCTION Get_Attr_Val_Id (p_Nda_Id IN NUMBER, p_Dh_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Val   Uss_Doc.Doc_Attributes.Da_Val_Id%TYPE;
    BEGIN
        SELECT MAX (a.Da_Val_Id)
          INTO l_Val
          FROM Uss_Doc.Doc_Attr2hist  h
               JOIN Uss_Doc.Doc_Attributes a
                   ON h.Da2h_Da = a.Da_Id AND a.Da_Nda = p_Nda_Id
         WHERE h.Da2h_Dh = p_Dh_Id;

        RETURN l_Val;
    END;
END Api$documents;
/