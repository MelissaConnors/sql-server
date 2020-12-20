--https://github.com/MelissaConnors
--find databases by name, count(*) for sys.foreign_keys.is_not_trusted = true
DECLARE @sql nvarchar(max);
SET @sql = N'';
SELECT @sql = @sql + N'UNION ALL 
  SELECT DBName = N''' + name + ''' COLLATE Latin1_General_BIN, 
  FKsNotTrusted =  
  (
    SELECT COUNT(*) AS FKsNotTrusted
      FROM ' + QUOTENAME(name) + '.sys.foreign_keys AS f'
   + N'
      WHERE f.is_not_trusted = 1 
        AND f.is_not_for_replication = 0 
        AND f.is_disabled = 0
  )
  ' FROM sys.databases 
WHERE database_id > 4 AND state = 0;

SET @sql = N'SELECT DBName, FKsNotTrusted FROM 
(' + STUFF(@sql, 1, 10, N'') 
   + N') AS x WHERE FKsNotTrusted > 0;';

EXEC sys.sp_executesql @sql;
