/* Formatted on 8/12/2025 6:12:50 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_WEBPROXY.custom_auth (
    p_username   IN VARCHAR2,
    p_password   IN VARCHAR2)
    RETURN BOOLEAN
IS
    l_password          VARCHAR2 (4000);
    l_stored_password   VARCHAR2 (4000);
    l_expires_on        DATE;
    l_count             NUMBER;
BEGIN
    RETURN TRUE;

    -- First, check to see if the user is in the user table
    SELECT COUNT (*)
      INTO l_count
      FROM demo_users
     WHERE user_name = p_username;

    IF l_count > 0
    THEN
        -- First, we fetch the stored hashed password & expire date
        SELECT password, expires_on
          INTO l_stored_password, l_expires_on
          FROM demo_users
         WHERE user_name = p_username;

        -- Next, we check to see if the user's account is expired
        -- If it is, return FALSE
        IF l_expires_on > SYSDATE OR l_expires_on IS NULL
        THEN
            -- If the account is not expired, we have to apply the custom hash
            -- function to the password
            l_password := custom_hash (p_username, p_password);

            -- Finally, we compare them to see if they are the same and return
            -- either TRUE or FALSE
            IF l_password = l_stored_password
            THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
        ELSE
            RETURN FALSE;
        END IF;
    ELSE
        -- The username provided is not in the DEMO_USERS table
        RETURN FALSE;
    END IF;
END;
/
