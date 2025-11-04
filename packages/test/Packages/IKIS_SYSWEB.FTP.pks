/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.ftp
AS
    -- --------------------------------------------------------------------------
    -- Name         : http://www.oracle-base.com/dba/miscellaneous/ftp.pks
    -- Author       : DR Timothy S Hall
    -- Description  : Basic FTP API.
    -- Requirements : UTL_TCP
    -- Ammedments   :
    --   When         Who       What
    --   ===========  ========  =================================================
    --   14-AUG-2003  Tim Hall  Initial Creation
    --   10-MAR-2004  Tim Hall  Add convert_crlf procedure.
    --                          Make get_passive function visible.
    --                          Added get_direct and put_direct procedures.
    -- --------------------------------------------------------------------------

    TYPE t_string_table IS TABLE OF VARCHAR2 (32767);

    FUNCTION login (p_host   IN VARCHAR2,
                    p_port   IN VARCHAR2,
                    p_user   IN VARCHAR2,
                    p_pass   IN VARCHAR2)
        RETURN UTL_TCP.connection;

    FUNCTION get_passive (p_conn IN OUT NOCOPY UTL_TCP.connection)
        RETURN UTL_TCP.connection;

    PROCEDURE LOGOUT (p_conn    IN OUT NOCOPY UTL_TCP.connection,
                      p_reply   IN            BOOLEAN := TRUE);

    PROCEDURE send_command (p_conn      IN OUT NOCOPY UTL_TCP.connection,
                            p_command   IN            VARCHAR2,
                            p_reply     IN            BOOLEAN := TRUE);

    FUNCTION get_local_ascii_data (p_dir IN VARCHAR2, p_file IN VARCHAR2)
        RETURN CLOB;

    FUNCTION get_local_binary_data (p_dir IN VARCHAR2, p_file IN VARCHAR2)
        RETURN BLOB;

    FUNCTION get_remote_ascii_data (
        p_conn   IN OUT NOCOPY UTL_TCP.connection,
        p_file   IN            VARCHAR2)
        RETURN CLOB;

    FUNCTION get_remote_filelist (p_conn       IN OUT NOCOPY UTL_TCP.connection,
                                  p_filespec   IN            VARCHAR2)
        RETURN t_string_table;

    PROCEDURE delete_remote_file (p_conn   IN OUT NOCOPY UTL_TCP.connection,
                                  p_file   IN            VARCHAR2);

    FUNCTION get_remote_binary_data (
        p_conn   IN OUT NOCOPY UTL_TCP.connection,
        p_file   IN            VARCHAR2)
        RETURN BLOB;

    PROCEDURE put_local_ascii_data (p_data   IN CLOB,
                                    p_dir    IN VARCHAR2,
                                    p_file   IN VARCHAR2);

    PROCEDURE put_local_binary_data (p_data   IN BLOB,
                                     p_dir    IN VARCHAR2,
                                     p_file   IN VARCHAR2);

    PROCEDURE put_remote_ascii_data (
        p_conn   IN OUT NOCOPY UTL_TCP.connection,
        p_file   IN            VARCHAR2,
        p_data   IN            CLOB);

    PROCEDURE put_remote_binary_data (
        p_conn   IN OUT NOCOPY UTL_TCP.connection,
        p_file   IN            VARCHAR2,
        p_data   IN            BLOB);

    PROCEDURE get (p_conn        IN OUT NOCOPY UTL_TCP.connection,
                   p_from_file   IN            VARCHAR2,
                   p_to_dir      IN            VARCHAR2,
                   p_to_file     IN            VARCHAR2);

    PROCEDURE put (p_conn        IN OUT NOCOPY UTL_TCP.connection,
                   p_from_dir    IN            VARCHAR2,
                   p_from_file   IN            VARCHAR2,
                   p_to_file     IN            VARCHAR2);

    PROCEDURE get_direct (p_conn        IN OUT NOCOPY UTL_TCP.connection,
                          p_from_file   IN            VARCHAR2,
                          p_to_dir      IN            VARCHAR2,
                          p_to_file     IN            VARCHAR2);

    PROCEDURE put_direct (p_conn        IN OUT NOCOPY UTL_TCP.connection,
                          p_from_dir    IN            VARCHAR2,
                          p_from_file   IN            VARCHAR2,
                          p_to_file     IN            VARCHAR2);

    PROCEDURE HELP (p_conn IN OUT NOCOPY UTL_TCP.connection);

    PROCEDURE ASCII (p_conn IN OUT NOCOPY UTL_TCP.connection);

    PROCEDURE binary (p_conn IN OUT NOCOPY UTL_TCP.connection);

    PROCEDURE convert_crlf (p_status IN BOOLEAN);
END ftp;
/


CREATE OR REPLACE PUBLIC SYNONYM FTP FOR IKIS_SYSWEB.FTP
/


GRANT EXECUTE ON IKIS_SYSWEB.FTP TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.FTP TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.ftp
AS
    -- --------------------------------------------------------------------------
    -- Name         : http://www.oracle-base.com/dba/miscellaneous/ftp.pkb
    -- Author       : DR Timothy S Hall
    -- Description  : Basic FTP API.
    -- Requirements : http://www.oracle-base.com/dba/miscellaneous/ftp.pks
    -- Ammedments   :
    --   When         Who       What
    --   ===========  ========  =================================================
    --   14-AUG-2003  Tim Hall  Initial Creation
    --   10-MAR-2004  Tim Hall  Add convert_crlf procedure.
    --                          Incorporate CRLF conversion functionality into
    --                          put_local_ascii_data and put_remote_ascii_data
    --                          functions.
    --                          Make get_passive function visible.
    --                          Added get_direct and put_direct procedures.
    --   23-DEC-2004  Tim Hall  The get_reply procedure was altered to deal with
    --                          banners starting with 4 white spaces. This fix is
    --                          a small variation on the resolution provided by
    --                          Gary Mason who spotted the bug.
    --   10-NOV-2005  Tim Hall  Addition of get_reply after doing a transfer to
    --                          pickup the 226 Transfer complete message. This
    --                          allows gets and puts with a single connection.
    --                          Issue spotted by Trevor Woolnough.
    -- --------------------------------------------------------------------------

    g_reply          t_string_table := t_string_table ();
    g_binary         BOOLEAN := TRUE;
    g_debug          BOOLEAN := FALSE;
    g_convert_crlf   BOOLEAN := TRUE;

    PROCEDURE get_reply (p_conn IN OUT NOCOPY UTL_TCP.connection);

    PROCEDURE debug (p_text IN VARCHAR2);

    -- --------------------------------------------------------------------------
    FUNCTION login (p_host   IN VARCHAR2,
                    p_port   IN VARCHAR2,
                    p_user   IN VARCHAR2,
                    p_pass   IN VARCHAR2)
        RETURN UTL_TCP.connection
    IS
        -- --------------------------------------------------------------------------
        l_conn   UTL_TCP.connection;
    BEGIN
        g_reply.delete;

        l_conn :=
            UTL_TCP.open_connection (p_host,
                                     p_port,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     UTL_TCP.CRLF,
                                     600);
        get_reply (l_conn);
        send_command (l_conn, 'USER ' || p_user);
        send_command (l_conn, 'PASS ' || p_pass);
        RETURN l_conn;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    FUNCTION get_passive (p_conn IN OUT NOCOPY UTL_TCP.connection)
        RETURN UTL_TCP.connection
    IS
        -- --------------------------------------------------------------------------
        l_conn    UTL_TCP.connection;
        l_reply   VARCHAR2 (32767);
        l_host    VARCHAR (100);
        l_port1   NUMBER (10);
        l_port2   NUMBER (10);
    BEGIN
        send_command (p_conn, 'PASV');
        l_reply := g_reply (g_reply.LAST);

        l_reply :=
            REPLACE (
                SUBSTR (l_reply,
                        INSTR (l_reply, '(') + 1,
                        (INSTR (l_reply, ')')) - (INSTR (l_reply, '(')) - 1),
                ',',
                '.');
        l_host :=
            SUBSTR (l_reply,
                    1,
                      INSTR (l_reply,
                             '.',
                             1,
                             4)
                    - 1);

        l_port1 :=
            TO_NUMBER (SUBSTR (l_reply,
                                 INSTR (l_reply,
                                        '.',
                                        1,
                                        4)
                               + 1,
                                 (  INSTR (l_reply,
                                           '.',
                                           1,
                                           5)
                                  - 1)
                               - (INSTR (l_reply,
                                         '.',
                                         1,
                                         4))));
        l_port2 :=
            TO_NUMBER (SUBSTR (l_reply,
                                 INSTR (l_reply,
                                        '.',
                                        1,
                                        5)
                               + 1));

        l_conn :=
            UTL_TCP.open_connection (l_host,
                                     256 * l_port1 + l_port2,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     UTL_TCP.CRLF,
                                     600);
        RETURN l_conn;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE LOGOUT (p_conn    IN OUT NOCOPY UTL_TCP.connection,
                      p_reply   IN            BOOLEAN := TRUE)
    AS
    -- --------------------------------------------------------------------------
    BEGIN
        send_command (p_conn, 'QUIT', p_reply);
        UTL_TCP.close_connection (p_conn);
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE send_command (p_conn      IN OUT NOCOPY UTL_TCP.connection,
                            p_command   IN            VARCHAR2,
                            p_reply     IN            BOOLEAN := TRUE)
    IS
        -- --------------------------------------------------------------------------
        l_result   PLS_INTEGER;
    BEGIN
        l_result := UTL_TCP.write_line (p_conn, p_command);

        IF p_reply
        THEN
            get_reply (p_conn);
        END IF;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE get_reply (p_conn IN OUT NOCOPY UTL_TCP.connection)
    IS
        -- --------------------------------------------------------------------------
        l_reply_code   VARCHAR2 (3) := NULL;
    BEGIN
        LOOP
            g_reply.EXTEND;
            g_reply (g_reply.LAST) := UTL_TCP.get_line (p_conn, TRUE);
            debug (g_reply (g_reply.LAST));

            IF l_reply_code IS NULL
            THEN
                l_reply_code := SUBSTR (g_reply (g_reply.LAST), 1, 3);
            END IF;

            IF SUBSTR (l_reply_code, 1, 1) = '5'
            THEN
                RAISE_APPLICATION_ERROR (-20000, g_reply (g_reply.LAST));
            ELSIF (    SUBSTR (g_reply (g_reply.LAST), 1, 3) = l_reply_code
                   AND SUBSTR (g_reply (g_reply.LAST), 4, 1) = ' ')
            THEN
                EXIT;
            END IF;
        END LOOP;
    EXCEPTION
        WHEN UTL_TCP.END_OF_INPUT
        THEN
            NULL;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    FUNCTION get_local_ascii_data (p_dir IN VARCHAR2, p_file IN VARCHAR2)
        RETURN CLOB
    IS
        -- --------------------------------------------------------------------------
        l_bfile   BFILE;
        l_data    CLOB;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc   => l_data,
                                  cache     => TRUE,
                                  dur       => DBMS_LOB.call);

        l_bfile := BFILENAME (p_dir, p_file);
        DBMS_LOB.fileopen (l_bfile, DBMS_LOB.file_readonly);
        DBMS_LOB.loadfromfile (l_data, l_bfile, DBMS_LOB.getlength (l_bfile));
        DBMS_LOB.fileclose (l_bfile);

        RETURN l_data;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    FUNCTION get_local_binary_data (p_dir IN VARCHAR2, p_file IN VARCHAR2)
        RETURN BLOB
    IS
        -- --------------------------------------------------------------------------
        l_bfile   BFILE;
        l_data    BLOB;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc   => l_data,
                                  cache     => TRUE,
                                  dur       => DBMS_LOB.call);

        l_bfile := BFILENAME (p_dir, p_file);
        DBMS_LOB.fileopen (l_bfile, DBMS_LOB.file_readonly);
        DBMS_LOB.loadfromfile (l_data, l_bfile, DBMS_LOB.getlength (l_bfile));
        DBMS_LOB.fileclose (l_bfile);

        RETURN l_data;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    FUNCTION get_remote_ascii_data (
        p_conn   IN OUT NOCOPY UTL_TCP.connection,
        p_file   IN            VARCHAR2)
        RETURN CLOB
    IS
        -- --------------------------------------------------------------------------
        l_conn     UTL_TCP.connection;
        l_amount   PLS_INTEGER;
        l_buffer   VARCHAR2 (32767);
        l_data     CLOB;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc   => l_data,
                                  cache     => TRUE,
                                  dur       => DBMS_LOB.call);

        l_conn := get_passive (p_conn);
        send_command (p_conn, 'RETR ' || p_file, TRUE);
        LOGOUT (l_conn, FALSE);

        BEGIN
            LOOP
                l_amount := UTL_TCP.read_text (l_conn, l_buffer, 32767);
                DBMS_LOB.writeappend (l_data, l_amount, l_buffer);
            END LOOP;
        EXCEPTION
            WHEN UTL_TCP.END_OF_INPUT
            THEN
                NULL;
            WHEN OTHERS
            THEN
                NULL;
        END;

        get_reply (p_conn);
        UTL_TCP.close_connection (l_conn);

        RETURN l_data;
    END;

    -- --------------------------------------------------------------------------

    PROCEDURE delete_remote_file (p_conn   IN OUT NOCOPY UTL_TCP.connection,
                                  p_file   IN            VARCHAR2)
    IS
        l_conn   UTL_TCP.connection;
    BEGIN
        --l_conn := get_passive(p_conn);
        send_command (p_conn, 'DELE ' || p_file, FALSE);
    --UTL_TCP.close_connection(l_conn);
    END;


    -- --------------------------------------------------------------------------
    FUNCTION get_remote_filelist (p_conn       IN OUT NOCOPY UTL_TCP.connection,
                                  p_filespec   IN            VARCHAR2)
        RETURN t_string_table
    IS
        -- --------------------------------------------------------------------------
        l_conn        UTL_TCP.connection;
        l_amount      PLS_INTEGER;
        l_buffer      RAW (32767);
        l_line        VARCHAR2 (32767);
        l_ftp_lines   t_string_table;
        l_pos         INT;
    BEGIN
        l_conn := get_passive (p_conn);
        send_command (p_conn, 'LIST ' || p_filespec, TRUE);
        l_ftp_lines := t_string_table ();

        BEGIN
            LOOP
                l_amount := UTL_TCP.read_line (l_conn, l_line);
                l_pos := INSTR (l_line, ' ', -1);
                l_line :=
                    SUBSTR (l_line, l_pos + 1, LENGTH (l_line) - l_pos - 1);
                l_ftp_lines.EXTEND;
                l_ftp_lines (l_ftp_lines.LAST) := l_line;
            END LOOP;
        EXCEPTION
            WHEN UTL_TCP.END_OF_INPUT
            THEN
                NULL;
            WHEN OTHERS
            THEN
                NULL;
        END;

        get_reply (p_conn);
        UTL_TCP.close_connection (l_conn);

        RETURN l_ftp_lines;
    END;

    -- --------------------------------------------------------------------------

    -- --------------------------------------------------------------------------
    FUNCTION get_remote_binary_data (
        p_conn   IN OUT NOCOPY UTL_TCP.connection,
        p_file   IN            VARCHAR2)
        RETURN BLOB
    IS
        -- --------------------------------------------------------------------------
        l_conn     UTL_TCP.connection;
        l_amount   PLS_INTEGER;
        l_buffer   RAW (32767);
        l_data     BLOB;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc   => l_data,
                                  cache     => TRUE,
                                  dur       => DBMS_LOB.call);

        l_conn := get_passive (p_conn);
        send_command (p_conn, 'RETR ' || p_file, TRUE);

        BEGIN
            LOOP
                l_amount := UTL_TCP.read_raw (l_conn, l_buffer, 32767);
                DBMS_LOB.writeappend (l_data, l_amount, l_buffer);
            END LOOP;
        EXCEPTION
            WHEN UTL_TCP.END_OF_INPUT
            THEN
                NULL;
            WHEN OTHERS
            THEN
                NULL;
        END;

        get_reply (p_conn);
        UTL_TCP.close_connection (l_conn);

        RETURN l_data;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE put_local_ascii_data (p_data   IN CLOB,
                                    p_dir    IN VARCHAR2,
                                    p_file   IN VARCHAR2)
    IS
        -- --------------------------------------------------------------------------
        l_out_file   UTL_FILE.file_type;
        l_buffer     VARCHAR2 (32767);
        l_amount     BINARY_INTEGER := 32767;
        l_pos        INTEGER := 1;
        l_clob_len   INTEGER;
    BEGIN
        l_clob_len := DBMS_LOB.getlength (p_data);

        l_out_file :=
            UTL_FILE.fopen (p_dir,
                            p_file,
                            'w',
                            32767);

        WHILE l_pos < l_clob_len
        LOOP
            DBMS_LOB.read (p_data,
                           l_amount,
                           l_pos,
                           l_buffer);

            IF g_convert_crlf
            THEN
                l_buffer := REPLACE (l_buffer, CHR (13), NULL);
            END IF;

            UTL_FILE.put (l_out_file, l_buffer);
            UTL_FILE.fflush (l_out_file);
            l_pos := l_pos + l_amount;
        END LOOP;

        UTL_FILE.fclose (l_out_file);
    EXCEPTION
        WHEN OTHERS
        THEN
            IF UTL_FILE.is_open (l_out_file)
            THEN
                UTL_FILE.fclose (l_out_file);
            END IF;

            RAISE;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE put_local_binary_data (p_data   IN BLOB,
                                     p_dir    IN VARCHAR2,
                                     p_file   IN VARCHAR2)
    IS
        -- --------------------------------------------------------------------------
        l_out_file   UTL_FILE.file_type;
        l_buffer     RAW (32767);
        l_amount     BINARY_INTEGER := 32767;
        l_pos        INTEGER := 1;
        l_blob_len   INTEGER;
    BEGIN
        l_blob_len := DBMS_LOB.getlength (p_data);

        l_out_file :=
            UTL_FILE.fopen (p_dir,
                            p_file,
                            'w',
                            32767);

        WHILE l_pos < l_blob_len
        LOOP
            DBMS_LOB.read (p_data,
                           l_amount,
                           l_pos,
                           l_buffer);
            UTL_FILE.put_raw (l_out_file, l_buffer, TRUE);
            UTL_FILE.fflush (l_out_file);
            l_pos := l_pos + l_amount;
        END LOOP;

        UTL_FILE.fclose (l_out_file);
    EXCEPTION
        WHEN OTHERS
        THEN
            IF UTL_FILE.is_open (l_out_file)
            THEN
                UTL_FILE.fclose (l_out_file);
            END IF;

            RAISE;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE put_remote_ascii_data (
        p_conn   IN OUT NOCOPY UTL_TCP.connection,
        p_file   IN            VARCHAR2,
        p_data   IN            CLOB)
    IS
        -- --------------------------------------------------------------------------
        l_conn       UTL_TCP.connection;
        l_result     PLS_INTEGER;
        l_buffer     VARCHAR2 (32767);
        l_amount     BINARY_INTEGER := 32767;
        l_pos        INTEGER := 1;
        l_clob_len   INTEGER;
    BEGIN
        l_conn := get_passive (p_conn);

        l_clob_len := DBMS_LOB.getlength (p_data);
        send_command (p_conn, 'STOR ' || p_file, TRUE);

        WHILE l_pos < l_clob_len
        LOOP
            DBMS_LOB.READ (p_data,
                           l_amount,
                           l_pos,
                           l_buffer);

            IF g_convert_crlf
            THEN
                l_buffer := REPLACE (l_buffer, CHR (13), NULL);
            END IF;

            l_result :=
                UTL_TCP.write_text (l_conn, l_buffer, LENGTH (l_buffer));
            UTL_TCP.flush (l_conn);
            l_pos := l_pos + l_amount;
        END LOOP;

        UTL_TCP.close_connection (l_conn);
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE put_remote_binary_data (
        p_conn   IN OUT NOCOPY UTL_TCP.connection,
        p_file   IN            VARCHAR2,
        p_data   IN            BLOB)
    IS
        -- --------------------------------------------------------------------------
        l_conn       UTL_TCP.connection;
        l_result     PLS_INTEGER;
        l_buffer     RAW (32767);
        l_amount     BINARY_INTEGER := 50;
        l_pos        INTEGER := 1;
        l_blob_len   INTEGER;
    BEGIN
        l_conn := get_passive (p_conn);
        send_command (p_conn, 'STOR ' || p_file, TRUE);
        l_blob_len := DBMS_LOB.getlength (p_data);

        WHILE l_pos < l_blob_len
        LOOP
            DBMS_LOB.READ (p_data,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_result := UTL_TCP.write_raw (l_conn, l_buffer, l_amount);
            UTL_TCP.flush (l_conn);
            l_pos := l_pos + l_amount;
        END LOOP;

        UTL_TCP.close_connection (l_conn);
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE get (p_conn        IN OUT NOCOPY UTL_TCP.connection,
                   p_from_file   IN            VARCHAR2,
                   p_to_dir      IN            VARCHAR2,
                   p_to_file     IN            VARCHAR2)
    AS
    -- --------------------------------------------------------------------------
    BEGIN
        IF g_binary
        THEN
            put_local_binary_data (
                p_data   => get_remote_binary_data (p_conn, p_from_file),
                p_dir    => p_to_dir,
                p_file   => p_to_file);
        ELSE
            put_local_ascii_data (
                p_data   => get_remote_ascii_data (p_conn, p_from_file),
                p_dir    => p_to_dir,
                p_file   => p_to_file);
        END IF;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE put (p_conn        IN OUT NOCOPY UTL_TCP.connection,
                   p_from_dir    IN            VARCHAR2,
                   p_from_file   IN            VARCHAR2,
                   p_to_file     IN            VARCHAR2)
    AS
    -- --------------------------------------------------------------------------
    BEGIN
        IF g_binary
        THEN
            put_remote_binary_data (
                p_conn   => p_conn,
                p_file   => p_to_file,
                p_data   => get_local_binary_data (p_from_dir, p_from_file));
        ELSE
            put_remote_ascii_data (
                p_conn   => p_conn,
                p_file   => p_to_file,
                p_data   => get_local_ascii_data (p_from_dir, p_from_file));
        END IF;

        get_reply (p_conn);
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE get_direct (p_conn        IN OUT NOCOPY UTL_TCP.connection,
                          p_from_file   IN            VARCHAR2,
                          p_to_dir      IN            VARCHAR2,
                          p_to_file     IN            VARCHAR2)
    IS
        -- --------------------------------------------------------------------------
        l_conn         UTL_TCP.connection;
        l_out_file     UTL_FILE.file_type;
        l_amount       PLS_INTEGER;
        l_buffer       VARCHAR2 (32767);
        l_raw_buffer   RAW (32767);
    BEGIN
        l_conn := get_passive (p_conn);
        send_command (p_conn, 'RETR ' || p_from_file, TRUE);
        l_out_file :=
            UTL_FILE.fopen (p_to_dir,
                            p_to_file,
                            'w',
                            32767);

        BEGIN
            LOOP
                IF g_binary
                THEN
                    l_amount :=
                        UTL_TCP.read_raw (l_conn, l_raw_buffer, 32767);
                    UTL_FILE.put_raw (l_out_file, l_raw_buffer, TRUE);
                ELSE
                    l_amount := UTL_TCP.read_text (l_conn, l_buffer, 32767);

                    IF g_convert_crlf
                    THEN
                        l_buffer := REPLACE (l_buffer, CHR (13), NULL);
                    END IF;

                    UTL_FILE.put (l_out_file, l_buffer);
                END IF;

                UTL_FILE.fflush (l_out_file);
            END LOOP;
        EXCEPTION
            WHEN UTL_TCP.END_OF_INPUT
            THEN
                NULL;
            WHEN OTHERS
            THEN
                NULL;
        END;

        UTL_FILE.fclose (l_out_file);
        UTL_TCP.close_connection (l_conn);
    EXCEPTION
        WHEN OTHERS
        THEN
            IF UTL_FILE.is_open (l_out_file)
            THEN
                UTL_FILE.fclose (l_out_file);
            END IF;

            RAISE;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE put_direct (p_conn        IN OUT NOCOPY UTL_TCP.connection,
                          p_from_dir    IN            VARCHAR2,
                          p_from_file   IN            VARCHAR2,
                          p_to_file     IN            VARCHAR2)
    IS
        -- --------------------------------------------------------------------------
        l_conn         UTL_TCP.connection;
        l_bfile        BFILE;
        l_result       PLS_INTEGER;
        l_amount       PLS_INTEGER := 32767;
        l_raw_buffer   RAW (32767);
        l_len          NUMBER;
        l_pos          NUMBER := 1;
        ex_ascii       EXCEPTION;
    BEGIN
        IF NOT g_binary
        THEN
            RAISE ex_ascii;
        END IF;

        l_conn := get_passive (p_conn);
        send_command (p_conn, 'STOR ' || p_to_file, TRUE);

        l_bfile := BFILENAME (p_from_dir, p_from_file);

        DBMS_LOB.fileopen (l_bfile, DBMS_LOB.file_readonly);
        l_len := DBMS_LOB.getlength (l_bfile);

        WHILE l_pos < l_len
        LOOP
            DBMS_LOB.READ (l_bfile,
                           l_amount,
                           l_pos,
                           l_raw_buffer);
            debug (l_amount);
            l_result := UTL_TCP.write_raw (l_conn, l_raw_buffer, l_amount);
            l_pos := l_pos + l_amount;
        END LOOP;

        DBMS_LOB.fileclose (l_bfile);
        UTL_TCP.close_connection (l_conn);
    EXCEPTION
        WHEN ex_ascii
        THEN
            RAISE_APPLICATION_ERROR (
                -20000,
                'PUT_DIRECT not available in ASCII mode.');
        WHEN OTHERS
        THEN
            IF DBMS_LOB.fileisopen (l_bfile) = 1
            THEN
                DBMS_LOB.fileclose (l_bfile);
            END IF;

            RAISE;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE HELP (p_conn IN OUT NOCOPY UTL_TCP.connection)
    AS
    -- --------------------------------------------------------------------------
    BEGIN
        send_command (p_conn, 'HELP', TRUE);
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE ASCII (p_conn IN OUT NOCOPY UTL_TCP.connection)
    AS
    -- --------------------------------------------------------------------------
    BEGIN
        send_command (p_conn, 'TYPE A', TRUE);
        g_binary := FALSE;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE binary (p_conn IN OUT NOCOPY UTL_TCP.connection)
    AS
    -- --------------------------------------------------------------------------
    BEGIN
        send_command (p_conn, 'TYPE I', TRUE);
        g_binary := TRUE;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE convert_crlf (p_status IN BOOLEAN)
    AS
    -- --------------------------------------------------------------------------
    BEGIN
        g_convert_crlf := p_status;
    END;

    -- --------------------------------------------------------------------------



    -- --------------------------------------------------------------------------
    PROCEDURE debug (p_text IN VARCHAR2)
    IS
    -- --------------------------------------------------------------------------
    BEGIN
        IF g_debug
        THEN
            DBMS_OUTPUT.put_line (SUBSTR (p_text, 1, 255));
        END IF;
    END;
-- --------------------------------------------------------------------------

END ftp;
/