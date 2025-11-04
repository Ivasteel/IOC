/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.DNET$EMAIL
IS
    -- Author  : SHOST
    -- Created : 22.01.2023 14:41:44
    -- Purpose : Обробка e-mail повідомлень сервісом

    PROCEDURE Get_Mailbox_List (p_Info     IN     VARCHAR2,
                                p_Cursor      OUT SYS_REFCURSOR);

    PROCEDURE Get_Out_Mail_List (p_Mb_Id       IN     NUMBER,
                                 p_Mail_List      OUT SYS_REFCURSOR);

    PROCEDURE Get_Out_Mail_Attachs (p_Mail_Id       IN     NUMBER,
                                    p_Attach_List      OUT SYS_REFCURSOR);

    PROCEDURE Set_Out_Mail_Sent (p_Mail_Id IN NUMBER);

    PROCEDURE Set_Out_Mail_Error (p_Mail_Id        IN NUMBER,
                                  p_Message        IN VARCHAR2,
                                  p_Is_Permanent   IN VARCHAR2);

    PROCEDURE After_Sent (p_Mb_Id IN NUMBER);
END Dnet$email;
/


GRANT EXECUTE ON USS_PERSON.DNET$EMAIL TO II01RC_USS_PERSON_SVC
/

GRANT EXECUTE ON USS_PERSON.DNET$EMAIL TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:57:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.DNET$EMAIL
IS
    ---------------------------------------------------------------
    -- Отримання переліку поштових скриньок
    ---------------------------------------------------------------
    PROCEDURE Get_Mailbox_List (p_Info     IN     VARCHAR2,
                                p_Cursor      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Cursor FOR
            --Заглушка
            SELECT 1                             AS Mb_Id,
                   Tools.Ggp ('MB_ADDRESS')      AS Mb_Address,
                   Tools.Ggp ('MB_PASSWORD')     AS Mb_Password,
                   Tools.Ggp ('MB_DOMAIN')       AS Mb_Domain
              FROM DUAL;
    END;

    ---------------------------------------------------------------
    -- Отримання переліку листів на відправку
    ---------------------------------------------------------------
    PROCEDURE Get_Out_Mail_List (p_Mb_Id       IN     NUMBER,
                                 p_Mail_List      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Mail_List FOR
              SELECT m.Ntmt_Id
                         AS Mail_Id,
                     Ntmt_Contact
                         AS Mail_Addr,
                     NULL
                         AS Mail_Copy,
                     Api$nt_Process.Getmessagetext (2, Ntm_Title, Ntst_Info_Tp)
                         AS Mail_Subject,
                     Api$nt_Process.Getmessagetext (1, Ntm_Text, Ntst_Info_Tp)
                         AS Mail_Body,
                     'Єдина інформаційна система соціальної сфери'
                         AS Mail_From
                FROM v_Nt_Send_Task t
                     JOIN v_Nt_Msg2task m ON t.Ntst_Id = m.Ntmt_Ntst
               WHERE     t.Ntst_Info_Tp = 'EMAIL'
                     AND t.Ntst_St IN ('C', 'P')
                     AND NVL (t.Ntst_Schedule_Dt, SYSDATE) <= SYSDATE
                     AND m.Ntmt_St = 'R'
            ORDER BY NVL (t.Ntst_Schedule_Dt, t.Ntst_Register_Dt),
                     m.Ntm_Register_Dt;
    END;

    ---------------------------------------------------------------
    -- Отримання переліку вкладень для вихідного листа
    ---------------------------------------------------------------
    PROCEDURE Get_Out_Mail_Attachs (p_Mail_Id       IN     NUMBER,
                                    p_Attach_List      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Attach_List FOR SELECT NULL     AS Attach_Id,
                                      NULL     AS Attach_Name,
                                      NULL     AS Attach_Mimetype,
                                      NULL     AS Attach_Blob,
                                      NULL     AS Attach_File_Code
                                 FROM DUAL
                                WHERE 1 = 2;
    END;

    ---------------------------------------------------------------
    -- Встановлення статусу повідомлення "відправлено"
    ---------------------------------------------------------------
    PROCEDURE Set_Out_Mail_Sent (p_Mail_Id IN NUMBER)
    IS
    BEGIN
        Api$nt_Process.Setntmtdelivered2person (p_Id             => p_Mail_Id,
                                                p_Delivered_Dt   => SYSDATE,
                                                p_Need_Commit    => FALSE);
    END;

    ---------------------------------------------------------------
    -- Встановлення статусу повідомлення "Помилка"
    ---------------------------------------------------------------
    PROCEDURE Set_Out_Mail_Error (p_Mail_Id        IN NUMBER,
                                  p_Message        IN VARCHAR2,
                                  p_Is_Permanent   IN VARCHAR2)
    IS
    BEGIN
        --Якщо помилка "постійна", тобто не залежить від пробем зі звязком, поштовим сервером, тощо
        IF p_Is_Permanent = 'T'
        THEN
            Api$nt_Process.Setntmtundelivered2person (
                p_Id            => p_Mail_Id,
                p_Hs            => Tools.Gethistsession,
                p_Message       => p_Message,
                p_Need_Commit   => FALSE);
        ELSE
            --todo: десь зафіксувати факт помилки?
            NULL;
        END IF;
    END;

    ---------------------------------------------------------------
    -- Процедура, що виконується після відправки порції листів
    ---------------------------------------------------------------
    PROCEDURE After_Sent (p_Mb_Id IN NUMBER)
    IS
    BEGIN
        Api$nt_Process.Checkntststate;
    END;
END Dnet$email;
/