/* Formatted on 8/12/2025 6:11:35 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.Get_Crypto_Key_Types (
    p_Key_Storage_Tp   VARCHAR2 DEFAULT NULL)
    RETURN CLOB
IS
    v_Result    CLOB := '';
    v_Ca_Data   VARCHAR2 (32000) := '';
BEGIN
    FOR Rec
        IN (  SELECT t.Lkt_Id,
                     t.Lkt_Name,
                     t.Lkt_Key_Mask,
                     t.Lkt_Storage_Tp,
                     t.Lkt_Ca
                FROM w_Login_Key_Type t
               WHERE     t.Lkt_Is_Active = 'A'
                     AND t.Lkt_Storage_Tp IS NOT NULL
                     AND t.Lkt_Storage_Tp =
                         NVL (p_Key_Storage_Tp, t.Lkt_Storage_Tp)
            ORDER BY t.Lkt_Num)
    LOOP
        IF Rec.Lkt_Ca IS NOT NULL
        THEN
            v_Ca_Data := Get_Ca_Data (Rec.Lkt_Ca);
        ELSE
            v_Ca_Data := 'null';
        END IF;

        v_Result :=
               v_Result
            || '{"id": '
            || Rec.Lkt_Id
            || ', "name": "'
            || Rec.Lkt_Name
            || '", "keyStorageType": "'
            || Rec.Lkt_Storage_Tp
            || '", "keyMediaTypeMask":"'
            || Rec.Lkt_Key_Mask
            || '", "caData": '
            || v_Ca_Data
            || '},';
    END LOOP;

    v_Result := '[' || RTRIM (v_Result, ',') || ']';
    RETURN v_Result;
END Get_Crypto_Key_Types;
/
