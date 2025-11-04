/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_DOC.DNET$DOCUMENTS
IS
    -- Author  : SHOSTAK
    -- Created : 25.05.2021 16:46:43
    -- Purpose :

    Package_Name   CONSTANT VARCHAR2 (100) := 'DNET$DOCUMENTS';

    PROCEDURE Register_Document (p_Doc_Id      OUT NUMBER,
                                 p_Dh_Id       OUT NUMBER,
                                 p_Src_Id   IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE Save_Doc_Hist (p_Doc_Ndt         IN     NUMBER,
                             p_Doc_Actuality   IN     VARCHAR2,
                             p_Doc_Id          IN OUT NUMBER,
                             p_Dh_Id           IN OUT NUMBER,
                             p_Src_Id          IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE Get_Doc_Hist (p_Doc_Id   IN     NUMBER,
                            p_Dh_Id    IN OUT NUMBER,
                            p_Res         OUT SYS_REFCURSOR);

    PROCEDURE Save_File (
        p_File_Id            IN     Files.File_Id%TYPE,
        p_File_Thumb         IN     Files.File_Thumb%TYPE,
        p_File_Code          IN OUT Files.File_Code%TYPE,
        p_File_Name          IN     Files.File_Name%TYPE,
        p_File_Mime_Type     IN     Files.File_Mime_Type%TYPE,
        p_File_Description   IN     Files.File_Description%TYPE,
        p_File_Hash          IN     Files.File_Hash%TYPE,
        p_File_Size          IN     Files.File_Size%TYPE,
        p_New_Id                OUT Files.File_Id%TYPE);

    PROCEDURE Save_Attachment (
        p_Doc_Id                 NUMBER,
        p_Dat_Num         IN     Doc_Attachments.Dat_Num%TYPE,
        p_Dat_File        IN     Doc_Attachments.Dat_File%TYPE,
        p_Dat_Dh          IN     Doc_Attachments.Dat_Dh%TYPE,
        p_Dat_Sign_File   IN     Doc_Attachments.Dat_Sign_File%TYPE,
        p_Dat_Hs          IN     Doc_Attachments.Dat_Hs%TYPE DEFAULT NULL,
        p_New_Id             OUT Doc_Attachments.Dat_Id%TYPE);

    PROCEDURE Save_Signed_Attachment_By_Code (
        p_Doc_Id                  NUMBER,
        p_Dat_Num          IN     Doc_Attachments.Dat_Num%TYPE,
        p_File_Code        IN     Files.File_Code%TYPE,
        p_Dat_Dh           IN     Doc_Attachments.Dat_Dh%TYPE,
        p_Dat_Sign_File    IN     Doc_Attachments.Dat_Sign_File%TYPE,
        p_File_Sign_Code   IN     Files.File_Code%TYPE,
        p_Dat_Hs           IN     Doc_Attachments.Dat_Hs%TYPE,
        p_New_Id              OUT Doc_Attachments.Dat_Id%TYPE);

    PROCEDURE Save_Attachment_By_Code (
        p_Doc_Id                 NUMBER,
        p_Dat_Num         IN     Doc_Attachments.Dat_Num%TYPE,
        p_File_Code       IN     Files.File_Code%TYPE,
        p_Dat_Dh          IN     Doc_Attachments.Dat_Dh%TYPE,
        p_Dat_Sign_File   IN     Doc_Attachments.Dat_Sign_File%TYPE,
        p_Dat_Hs          IN     Doc_Attachments.Dat_Hs%TYPE DEFAULT NULL,
        p_New_Id             OUT Doc_Attachments.Dat_Id%TYPE);

    PROCEDURE Save_Attachment_Sign (p_Dh_Id            IN NUMBER,
                                    p_File_Code        IN VARCHAR2,
                                    p_File_Sign_Code   IN VARCHAR2,
                                    p_Hs_Id            IN NUMBER);

    PROCEDURE Get_Attachments (p_Doc_Id       NUMBER,
                               p_Dh_Id        NUMBER,
                               p_Res      OUT SYS_REFCURSOR);

    PROCEDURE Get_File_Id (p_File_Code VARCHAR2, p_File_Id OUT NUMBER);

    PROCEDURE Save_File_Log (p_File_Code IN VARCHAR2);
END Dnet$documents;
/


GRANT EXECUTE ON USS_DOC.DNET$DOCUMENTS TO DNET_PROXY
/

GRANT EXECUTE ON USS_DOC.DNET$DOCUMENTS TO II01RC_USS_DOC_WEB
/

GRANT EXECUTE ON USS_DOC.DNET$DOCUMENTS TO OKOMISAROV
/

GRANT EXECUTE ON USS_DOC.DNET$DOCUMENTS TO SERVICE_PROXY
/

GRANT EXECUTE ON USS_DOC.DNET$DOCUMENTS TO SHOST
/


/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_DOC.DNET$DOCUMENTS
IS
    PROCEDURE Register_Document (p_Doc_Id      OUT NUMBER,
                                 p_Dh_Id       OUT NUMBER,
                                 p_Src_Id   IN     VARCHAR2 DEFAULT NULL)
    IS
        l_Dh_Wu    Doc_Hist.Dh_Wu%TYPE;
        l_Dh_Cu    Doc_Hist.Dh_Cu%TYPE;
        l_Dh_Src   Doc_Hist.Dh_Src%TYPE;
    BEGIN
        l_Dh_Wu := Uss_Doc_Context.Get_Context (Uss_Doc_Context.g_Uid);
        l_Dh_Cu := Uss_Doc_Context.Get_Context (Uss_Doc_Context.g_Cuid);
        l_Dh_Src :=
            NVL (
                p_Src_Id,
                Api$auth.Get_App_Code (
                    Uss_Doc_Context.Get_Context (Uss_Doc_Context.g_App)));

        Api$documents.Save_Document (
            p_Doc_Id          => NULL,
            p_Doc_Ndt         => NULL,
            p_Doc_Actuality   => Api$documents.c_Doc_Actuality_Undefined,
            p_New_Id          => p_Doc_Id);

        Api$documents.Save_Doc_Hist (
            p_Dh_Id          => NULL,
            p_Dh_Doc         => p_Doc_Id,
            p_Dh_Sign_Alg    => NULL,
            p_Dh_Ndt         => NULL,
            p_Dh_Sign_File   => NULL,
            p_Dh_Actuality   => Api$documents.c_Doc_Actuality_Undefined,
            p_Dh_Dt          => SYSDATE,
            p_Dh_Wu          => l_Dh_Wu,
            p_Dh_Cu          => l_Dh_Cu,
            p_Dh_Src         => l_Dh_Src,
            p_New_Id         => p_Dh_Id);
    END;

    PROCEDURE Save_Doc_Hist (p_Doc_Ndt         IN     NUMBER,
                             p_Doc_Actuality   IN     VARCHAR2,
                             p_Doc_Id          IN OUT NUMBER,
                             p_Dh_Id           IN OUT NUMBER,
                             p_Src_Id          IN     VARCHAR2 DEFAULT NULL)
    IS
        l_Dh_Wu           Doc_Hist.Dh_Wu%TYPE;
        l_Dh_Cu           Doc_Hist.Dh_Cu%TYPE;
        l_Dh_Src          Doc_Hist.Dh_Src%TYPE;
        l_Doc_Actuality   Documents.Doc_Actuality%TYPE;
    BEGIN
        l_Dh_Wu := Uss_Doc_Context.Get_Context (Uss_Doc_Context.g_Uid);
        l_Dh_Cu := Uss_Doc_Context.Get_Context (Uss_Doc_Context.g_Cuid);
        l_Dh_Src :=
            NVL (
                p_Src_Id,
                Api$auth.Get_App_Code (
                    Uss_Doc_Context.Get_Context (Uss_Doc_Context.g_App)));
        l_Doc_Actuality :=
            NVL (p_Doc_Actuality, Api$documents.c_Doc_Actuality_Undefined);

        Api$documents.Save_Document (p_Doc_Id          => p_Doc_Id,
                                     p_Doc_Ndt         => p_Doc_Ndt,
                                     p_Doc_Actuality   => l_Doc_Actuality,
                                     p_New_Id          => p_Doc_Id);

        Api$documents.Save_Doc_Hist (p_Dh_Id          => p_Dh_Id,
                                     p_Dh_Doc         => p_Doc_Id,
                                     p_Dh_Sign_Alg    => NULL,
                                     p_Dh_Ndt         => p_Doc_Ndt,
                                     p_Dh_Sign_File   => NULL,
                                     p_Dh_Actuality   => l_Doc_Actuality,
                                     p_Dh_Dt          => SYSDATE,
                                     p_Dh_Wu          => l_Dh_Wu,
                                     p_Dh_Cu          => l_Dh_Cu,
                                     p_Dh_Src         => l_Dh_Src,
                                     p_New_Id         => p_Dh_Id);
    END;

    PROCEDURE Get_Doc_Hist (p_Doc_Id   IN     NUMBER,
                            p_Dh_Id    IN OUT NUMBER,
                            p_Res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF p_Dh_Id IS NULL
        THEN
            p_Dh_Id := Api$documents.Get_Last_Doc_Hist (p_Dh_Doc => p_Doc_Id);
        END IF;

        OPEN p_Res FOR SELECT h.Dh_Doc,
                              h.Dh_Ndt,
                              h.Dh_Actuality,
                              h.Dh_Dt
                         FROM Doc_Hist h
                        WHERE h.Dh_Id = p_Dh_Id;
    END;

    PROCEDURE Save_File (
        p_File_Id            IN     Files.File_Id%TYPE,
        p_File_Thumb         IN     Files.File_Thumb%TYPE,
        p_File_Code          IN OUT Files.File_Code%TYPE,
        p_File_Name          IN     Files.File_Name%TYPE,
        p_File_Mime_Type     IN     Files.File_Mime_Type%TYPE,
        p_File_Description   IN     Files.File_Description%TYPE,
        p_File_Hash          IN     Files.File_Hash%TYPE,
        p_File_Size          IN     Files.File_Size%TYPE,
        p_New_Id                OUT Files.File_Id%TYPE)
    IS
        l_File_Wu    Files.File_Wu%TYPE;
        l_File_Cu    Files.File_Cu%TYPE;
        l_File_App   Files.File_App%TYPE;
    BEGIN
        l_File_Wu := Uss_Doc_Context.Get_Context (Uss_Doc_Context.g_Uid);
        l_File_Cu := Uss_Doc_Context.Get_Context (Uss_Doc_Context.g_Cuid);
        l_File_App := Uss_Doc_Context.Get_Context (Uss_Doc_Context.g_App);

        p_File_Code := NVL (p_File_Code, Api$documents.Generate_File_Code);

        Api$documents.Save_File (p_File_Id            => p_File_Id,
                                 p_File_Thumb         => p_File_Thumb,
                                 p_File_Code          => p_File_Code,
                                 p_File_Name          => p_File_Name,
                                 p_File_Mime_Type     => p_File_Mime_Type,
                                 p_File_Description   => p_File_Description,
                                 p_File_Create_Dt     => SYSDATE,
                                 p_File_Wu            => l_File_Wu,
                                 p_File_App           => l_File_App,
                                 p_File_Hash          => p_File_Hash,
                                 p_File_Size          => p_File_Size,
                                 p_File_Cu            => l_File_Cu,
                                 p_New_Id             => p_New_Id);
    END;

    PROCEDURE Save_Signed_Attachment_By_Code (
        p_Doc_Id                  NUMBER,
        p_Dat_Num          IN     Doc_Attachments.Dat_Num%TYPE,
        p_File_Code        IN     Files.File_Code%TYPE,
        p_Dat_Dh           IN     Doc_Attachments.Dat_Dh%TYPE,
        p_Dat_Sign_File    IN     Doc_Attachments.Dat_Sign_File%TYPE,
        p_File_Sign_Code   IN     Files.File_Code%TYPE,
        p_Dat_Hs           IN     Doc_Attachments.Dat_Hs%TYPE,
        p_New_Id              OUT Doc_Attachments.Dat_Id%TYPE)
    IS
        l_Dat_Sign_File   Doc_Attachments.Dat_Sign_File%TYPE;
    BEGIN
        IF p_Dat_Sign_File IS NOT NULL
        THEN
            l_Dat_Sign_File := p_Dat_Sign_File;
        ELSE
            SELECT MAX (File_Id)
              INTO l_Dat_Sign_File
              FROM Files
             WHERE File_Code = p_File_Sign_Code;
        END IF;

        Save_Attachment_By_Code (
            p_Doc_Id          => p_Doc_Id,
            p_Dat_Num         => p_Dat_Num,
            p_File_Code       => p_File_Code,
            p_Dat_Dh          => p_Dat_Dh,
            p_Dat_Sign_File   => l_Dat_Sign_File,
            p_Dat_Hs          => NVL (p_Dat_Hs, Tools.Gethistsession),
            p_New_Id          => p_New_Id);
    END;

    PROCEDURE Save_Attachment_By_Code (
        p_Doc_Id                 NUMBER,
        p_Dat_Num         IN     Doc_Attachments.Dat_Num%TYPE,
        p_File_Code       IN     Files.File_Code%TYPE,
        p_Dat_Dh          IN     Doc_Attachments.Dat_Dh%TYPE,
        p_Dat_Sign_File   IN     Doc_Attachments.Dat_Sign_File%TYPE,
        p_Dat_Hs          IN     Doc_Attachments.Dat_Hs%TYPE DEFAULT NULL,
        p_New_Id             OUT Doc_Attachments.Dat_Id%TYPE)
    IS
        l_Dh_Id      NUMBER;
        l_Dat_File   Doc_Attachments.Dat_File%TYPE;
    BEGIN
        IF NVL (p_Dat_Dh, p_Doc_Id) IS NULL
        THEN
            Raise_Application_Error (-20001,
                                     'Не вказано ІД документа та ІД зрізу');
        END IF;

        SELECT File_Id
          INTO l_Dat_File
          FROM Files
         WHERE File_Code = p_File_Code;

        --Если срез не указан явно, получаем последний срез документа по дате создания
        l_Dh_Id :=
            NVL (p_Dat_Dh,
                 Api$documents.Get_Last_Doc_Hist (p_Dh_Doc => p_Doc_Id));

        Api$documents.Save_Attachment (
            p_Dat_Id          => NULL,
            p_Dat_Num         => p_Dat_Num,
            p_Dat_File        => l_Dat_File,
            p_Dat_Dh          => l_Dh_Id,
            p_Dat_Sign_File   => p_Dat_Sign_File,
            p_Dat_Hs          => NVL (p_Dat_Hs, Tools.Gethistsession),
            p_New_Id          => p_New_Id);
    END;

    PROCEDURE Save_Attachment (
        p_Doc_Id                 NUMBER,
        p_Dat_Num         IN     Doc_Attachments.Dat_Num%TYPE,
        p_Dat_File        IN     Doc_Attachments.Dat_File%TYPE,
        p_Dat_Dh          IN     Doc_Attachments.Dat_Dh%TYPE,
        p_Dat_Sign_File   IN     Doc_Attachments.Dat_Sign_File%TYPE,
        p_Dat_Hs          IN     Doc_Attachments.Dat_Hs%TYPE DEFAULT NULL,
        p_New_Id             OUT Doc_Attachments.Dat_Id%TYPE)
    IS
        l_Dh_Id   NUMBER;
    BEGIN
        IF NVL (p_Dat_Dh, p_Doc_Id) IS NULL
        THEN
            Raise_Application_Error (-20001,
                                     'Не вказано ІД документа та ІД зрізу');
        END IF;

        --Если срез не указан явно, получаем последний срез документа по дате создания
        l_Dh_Id :=
            NVL (p_Dat_Dh,
                 Api$documents.Get_Last_Doc_Hist (p_Dh_Doc => p_Doc_Id));

        Api$documents.Save_Attachment (
            p_Dat_Id          => NULL,
            p_Dat_Num         => p_Dat_Num,
            p_Dat_File        => p_Dat_File,
            p_Dat_Dh          => l_Dh_Id,
            p_Dat_Sign_File   => p_Dat_Sign_File,
            p_Dat_Hs          => NVL (p_Dat_Hs, Tools.Gethistsession),
            p_New_Id          => p_New_Id);
    END;

    PROCEDURE Save_Attach_List (p_Doc_Id        NUMBER,
                                p_Dh_Id         NUMBER,
                                p_Attachments   CLOB         --перечень файлов
                                                    )
    IS
        l_Dh_Id   NUMBER;
    BEGIN
        --Если срез не указан явно, получаем последний срез документа по дате создания
        l_Dh_Id :=
            NVL (p_Dh_Id,
                 Api$documents.Get_Last_Doc_Hist (p_Dh_Doc => p_Doc_Id));

        FOR Rec
            IN (WITH
                    Dat
                    AS
                        (SELECT a.Dat_Id,
                                a.Dat_Num,
                                f.File_Id,
                                f.File_Code
                           FROM Doc_Attachments  a
                                JOIN Files f ON a.Dat_File = f.File_Id
                          WHERE a.Dat_Dh = l_Dh_Id),
                    Xdat
                    AS
                        (SELECT (COLUMN_VALUE).Getstringval ()
                                    AS File_Code,
                                ROWNUM
                                    AS Dat_Num
                           FROM XMLTABLE (p_Attachments))
                SELECT d.File_Id,
                       d.Dat_Id,
                       x.Dat_Num,
                       NVL (d.File_Code, x.File_Code)    AS File_Code,
                       CASE
                           WHEN x.File_Code IS NULL THEN 'DELETE'
                           WHEN x.Dat_Num <> d.Dat_Num THEN 'UPDATE'
                       END                               AS Operation
                  FROM Dat  d
                       FULL OUTER JOIN Xdat x ON d.File_Code = x.File_Code)
        LOOP
            CASE Rec.Operation
                WHEN 'DELETE'
                THEN
                    --Удаляем вложение
                    Api$documents.Delete_Attachment (p_Id => Rec.Dat_Id);
                --Запись в FILES должна остаться, для дальнейшего регламентого удаления
                --Если на файл не ссылок в других срезах/документах
                /*IF NOT Api$documents.File_Is_Attched2doc(p_File_Id => Rec.File_Id)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      THEN
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       --то удаляем его
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Api$documents.Delete_File(p_File_Id => Rec.File_Id);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      END IF;*/
                WHEN 'UPDATE'
                THEN
                    Api$documents.Set_Attachment_Num (
                        p_Dat_Id    => Rec.Dat_Id,
                        p_Dat_Num   => Rec.Dat_Num);
            END CASE;
        END LOOP;
    END;

    PROCEDURE Save_Attachment_Sign (p_Dh_Id            IN NUMBER,
                                    p_File_Code        IN VARCHAR2,
                                    p_File_Sign_Code   IN VARCHAR2,
                                    p_Hs_Id            IN NUMBER)
    IS
        l_Dat_Id         NUMBER;
        l_Sign_File_Id   NUMBER;
        l_Sign_Exists    NUMBER;
    BEGIN
        --Отримуємо ІД вклаження
        SELECT MAX (a.Dat_Id)
          INTO l_Dat_Id
          FROM Doc_Attachments a JOIN Files f ON a.Dat_File = f.File_Id
         WHERE a.Dat_Dh = p_Dh_Id AND f.File_Code = p_File_Code;

        --Отримуємо ІД файлу підпису
        Get_File_Id (p_File_Sign_Code, l_Sign_File_Id);

        --Перевіряємо наявність такого підпису у вкладення
        SELECT SIGN (COUNT (*))
          INTO l_Sign_Exists
          FROM Doc_Attach_Signs s
         WHERE s.Dats_Dat = l_Dat_Id AND s.Dats_Sign_File = l_Sign_File_Id;

        IF l_Sign_Exists = 0
        THEN
            --Привязуємо підпис до вкладення
            Api$documents.Save_Attachment_Sign (
                p_Dats_Dat         => l_Dat_Id,
                p_Dats_Sign_File   => l_Sign_File_Id,
                p_Dats_Hs          => NVL (p_Hs_Id, Tools.Gethistsession));
        END IF;
    END;

    PROCEDURE Get_Attachments (p_Doc_Id       NUMBER,
                               p_Dh_Id        NUMBER,
                               p_Res      OUT SYS_REFCURSOR)
    IS
        l_Dh_Id   NUMBER;
    BEGIN
        --Если срез не указан явно, получаем последний срез документа по дате создания
        l_Dh_Id :=
            NVL (p_Dh_Id,
                 Api$documents.Get_Last_Doc_Hist (p_Dh_Doc => p_Doc_Id));

        OPEN p_Res FOR
              SELECT f.File_Code,
                     f.File_Name,
                     f.File_Mime_Type,
                     f.File_Size,
                     f.File_Hash,
                     f.File_Create_Dt,
                     f.File_Description
                FROM Doc_Attachments a JOIN Files f ON a.Dat_File = f.File_Id
               WHERE a.Dat_Dh = l_Dh_Id
            ORDER BY a.Dat_Num;
    END;

    PROCEDURE Get_File_Id (p_File_Code VARCHAR2, p_File_Id OUT NUMBER)
    IS
    BEGIN
        SELECT f.File_Id
          INTO p_File_Id
          FROM Files f
         WHERE f.File_Code = p_File_Code;
    END;

    PROCEDURE Save_File_Log (p_File_Code IN VARCHAR2)
    IS
    BEGIN
        INSERT INTO File_Log (Fl_Id, Fl_Hs, Fl_File_Code)
             VALUES (0, Tools.Gethistsession, p_File_Code);
    END;
END Dnet$documents;
/