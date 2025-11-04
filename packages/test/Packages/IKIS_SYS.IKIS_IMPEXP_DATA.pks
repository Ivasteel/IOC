/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_IMPEXP_DATA
IS
    -- Author  : KYB
    -- Created : 29.06.2005 14:34:15
    -- Purpose : »мпорт/Ёкспорт данных

    --KYB 29.06.2005
    --получить параметры типа загрузки
    PROCEDURE GetImportProps (
        p_IIT_CODE         IN     IKIS_IMPORT_TYPES.IIT_CODE%TYPE,
        p_IIT_ID              OUT IKIS_IMPORT_TYPES.IIT_ID%TYPE,
        p_IIT_NAME            OUT IKIS_IMPORT_TYPES.IIT_NAME%TYPE,
        p_IIT_FILE_MASK       OUT IKIS_IMPORT_TYPES.IIT_FILE_MASK%TYPE,
        p_IIT_ARC_TP          OUT IKIS_IMPORT_TYPES.IIT_ARC_TP%TYPE,
        p_IIT_STORE_PROC      OUT IKIS_IMPORT_TYPES.IIT_STORE_PROC%TYPE,
        p_IIT_SUBSYS          OUT IKIS_IMPORT_TYPES.IIT_SUBSYS%TYPE,
        p_IIT_PROT_TYPE       OUT IKIS_IMPORT_TYPES.IIT_PROT_TYPE%TYPE);
/*  --KYB 16.08.2005
  --получить список параметров процедуры сохранени€ данных дл€ типа загрузки
  procedure GetImportProcParams(p_IIT_CODE       in IKIS_IMPORT_TYPES.IIT_CODE%type,
                                p_param_list     out varchar2);
*/
END IKIS_IMPEXP_DATA;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_IMPEXP_DATA FOR IKIS_SYS.IKIS_IMPEXP_DATA
/


GRANT EXECUTE ON IKIS_SYS.IKIS_IMPEXP_DATA TO II01RC_IKIS_IMPEXP_DATA
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_IMPEXP_DATA
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    PROCEDURE GetImportProps (
        p_IIT_CODE         IN     IKIS_IMPORT_TYPES.IIT_CODE%TYPE,
        p_IIT_ID              OUT IKIS_IMPORT_TYPES.IIT_ID%TYPE,
        p_IIT_NAME            OUT IKIS_IMPORT_TYPES.IIT_NAME%TYPE,
        p_IIT_FILE_MASK       OUT IKIS_IMPORT_TYPES.IIT_FILE_MASK%TYPE,
        p_IIT_ARC_TP          OUT IKIS_IMPORT_TYPES.IIT_ARC_TP%TYPE,
        p_IIT_STORE_PROC      OUT IKIS_IMPORT_TYPES.IIT_STORE_PROC%TYPE,
        p_IIT_SUBSYS          OUT IKIS_IMPORT_TYPES.IIT_SUBSYS%TYPE,
        p_IIT_PROT_TYPE       OUT IKIS_IMPORT_TYPES.IIT_PROT_TYPE%TYPE)
    IS
    BEGIN
        SELECT IIT_ID,
               IIT_NAME,
               IIT_FILE_MASK,
               IIT_ARC_TP,
               IIT_STORE_PROC,
               IIT_SUBSYS,
               IIT_PROT_TYPE
          INTO p_IIT_ID,
               p_IIT_NAME,
               p_IIT_FILE_MASK,
               p_IIT_ARC_TP,
               p_IIT_STORE_PROC,
               p_IIT_SUBSYS,
               p_IIT_PROT_TYPE
          FROM ikis_import_types
         WHERE iit_code = p_iit_code;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_IMPEXP_DATA.GetImportProps',
                    CHR (10) || SQLERRM));
    END;
/*procedure GetImportProcParams(p_IIT_CODE       in IKIS_IMPORT_TYPES.IIT_CODE%type,
                              p_param_list     out varchar2)
is
begin
  p_param_list := '';
  for c1 in (select iisp_type, iisp_name, iisp_value
             from IKIS_IMPORT_TYPES, IKIS_IMPORT_STORE_PAR
             where iit_code=p_IIT_CODE
               and iit_id=iisp_iit) loop
    p_param_list := p_param_list||chr(10)||
                                  c1.iisp_type||'|'||
                                  c1.iisp_name||'|'||
                                  c1.iisp_value;
  end loop;
  if substr(p_param_list,1,1)=chr(10) then
    p_param_list := substr(p_param_list,2,length(p_param_list)-1);
  end if;
exception
  when others then
    raise_application_error(-20000,ikis_message_util.Get_Message(msgCOMMON_EXCEPTION,'IKIS_IMPEXP_DATA.GetImportProcParams',chr(10)||sqlerrm));
end;
*/

END IKIS_IMPEXP_DATA;
/