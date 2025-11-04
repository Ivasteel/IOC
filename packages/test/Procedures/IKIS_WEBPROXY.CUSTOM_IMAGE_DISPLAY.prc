/* Formatted on 8/12/2025 6:12:51 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_WEBPROXY.custom_image_display (
    p_image_id   IN NUMBER)
AS
    l_mime        VARCHAR2 (255);
    l_length      NUMBER;
    l_file_name   VARCHAR2 (2000);
    lob_loc       BLOB;
BEGIN
    SELECT mime_type,
           image,
           image_name,
           DBMS_LOB.getlength (image)
      INTO l_mime,
           lob_loc,
           l_file_name,
           l_length
      FROM demo_images
     WHERE image_id = p_image_id;

    -- Set up HTTP header
    -- Use an NVL around the mime type and  if it is a null, set it to
    -- application/octect - which may launch a download window from windows
    OWA_UTIL.mime_header (NVL (l_mime, 'application/octet'), FALSE);

    -- Set the size so the browser knows how much to download htp.p('Content-length: ' || l_length);

    -- The filename will be used by the browser if the users does a "Save as" htp.p('Content-Disposition: filename="' || l_file_name || '"');

    -- Close the headers
    OWA_UTIL.http_header_close;

    -- Download the BLOB
    WPG_DOCLOAD.download_file (Lob_loc);
END;
/


GRANT EXECUTE ON IKIS_WEBPROXY.CUSTOM_IMAGE_DISPLAY TO PUBLIC
/
