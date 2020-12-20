--https://github.com/MelissaConnors
--find databases by name, count(*) for sys.check_constraints.is_not_trusted = true
DECLARE @sql nvarchar(max);
SET @sql = N'';
SELECT @sql = @sql + N'UNION ALL 
  SELECT DBName = N''' + name + ''' COLLATE Latin1_General_BIN, 
  CCsNotTrusted =  
  (
    SELECT COUNT(*) AS CCsNotTrusted
      FROM ' + QUOTENAME(name) + '.sys.check_constraints AS c'
      + N'
      WHERE c.is_not_trusted = 1 
        AND c.is_not_for_replication = 0 
        AND c.is_disabled = 0
  )
  ' FROM sys.databases 
WHERE database_id > 4 AND state = 0;
SET @sql = N'SELECT DBName, CCsNotTrusted FROM 
(' + STUFF(@sql, 1, 10, N'') 
   + N') AS x WHERE CCsNotTrusted > 0;';
EXEC sys.sp_executesql @sql;
