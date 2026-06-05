DROP FUNCTION IF EXISTS BIG_SEC_TO_TIME;
DELIMITER $$
CREATE FUNCTION BIG_SEC_TO_TIME(SECS BIGINT)
RETURNS TEXT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE HEURES TEXT;
    DECLARE MINUTES CHAR(5);
    DECLARE SECONDES CHAR(5);

    IF (SECS IS NULL) THEN RETURN NULL; END IF;

    SET HEURES = FLOOR(SECS / 3600);

    SET MINUTES = FLOOR((SECS - (HEURES*3600)) / 60);

    SET SECONDES = MOD(SECS, 60);

    IF MINUTES < 10 THEN SET MINUTES = CONCAT( "0", MINUTES); END IF;
    IF SECONDES < 10 THEN SET SECONDES = CONCAT( "0", SECONDES); END IF;

    RETURN CONCAT(HEURES, ":", MINUTES, ":", SECONDES);
END;
$$
DELIMITER ;

SELECT COUNT(DISTINCT(job_id)) AS n_ebrains_jobs,
    COUNT(DISTINCT(owner_name)) AS n_ebrains_users,
    SUM(allocation_size) AS n_ebrains_boards,
    BIG_SEC_TO_TIME(SUM(death_timestamp - create_timestamp)) AS time_ebrains,
    BIG_SEC_TO_TIME(SUM((death_timestamp - create_timestamp)
        * allocation_size * 48 * 16)) AS quota_ebrains
    FROM jobs
    WHERE owner_name LIKE "openid.%";
SELECT COUNT(DISTINCT(job_id)) AS n_jupyter_jobs,
    COUNT(DISTINCT(REGEXP_SUBSTR(CONVERT(original_request USING latin1),
        '\"Jupyter[^\"]*\"'))) AS n_jupyter_users,
    SUM(allocation_size) AS n_jupyter_boards,
    BIG_SEC_TO_TIME(SUM(death_timestamp - create_timestamp)) AS time_jupyter,
    BIG_SEC_TO_TIME(SUM((death_timestamp - create_timestamp)
        * allocation_size * 48 * 16)) AS quota_jupyter
    FROM jobs
    WHERE CONVERT(original_request USING latin1) LIKE BINARY "%Jupyter%";
SELECT COUNT(DISTINCT(job_id)) AS n_nmpi_jobs,
    COUNT(DISTINCT(REGEXP_SUBSTR(CONVERT(original_request USING latin1),
        '\"NMPI[^\"]*\"'))) AS n_nmpi_users,
    SUM(allocation_size) AS n_nmpi_boards,
    BIG_SEC_TO_TIME(SUM(death_timestamp - create_timestamp)) AS time_nmpi,
    BIG_SEC_TO_TIME(SUM((death_timestamp - create_timestamp)
        * allocation_size * 48 * 16)) AS quota_nmpi
    FROM jobs
    WHERE CONVERT(original_request USING latin1) LIKE BINARY "%NMPI%";
SELECT COUNT(DISTINCT(job_id)) AS n_other_jobs,
    COUNT(DISTINCT(owner_name)) AS n_other_users,
    SUM(allocation_size) AS n_other_boards,
    BIG_SEC_TO_TIME(SUM(death_timestamp - create_timestamp)) AS time_other,
    BIG_SEC_TO_TIME(SUM((death_timestamp - create_timestamp)
        * allocation_size * 48 * 16)) AS quota_other
    FROM jobs
    WHERE owner_name NOT LIKE "openid.%"
    AND owner_name != "jenkins"
    AND owner_name != "spalloc_classic"
    AND owner_name != "christian.brenninkmeijer@manchester.ac.uk"
    AND owner_name != "Christian-test"
    AND owner_name != "Christian-b";
