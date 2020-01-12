#!/bin/bash 

main () {
  if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]
  then
    echo "Three arguments needed. (schema, geometry_column, target_srid)"
    exit 1
  fi
  schema=$1
  geometry_column=$2
  target_srid=$3
  tables=$(get_tables_in_schema $schema)
  for table in $tables
  do
    geometry_type=$(get_geometry_type $schema $table $geometry_column)
    reproject_table $schema.$table $geometry_column $geometry_type $target_srid
  done

}

get_geometry_type () {
  schemaname=$1
  tablename=$2
  geometry_column=$3
  psqloutput=$(psql -c "SELECT type FROM geometry_columns WHERE f_table_schema = '$schemaname' AND f_table_name = '$tablename' AND f_geometry_column = '$geometry_column';")
  echo $psqloutput | awk '{print $3}'
}

reproject_table () {
  tablenamewithschema=$1
  geometry_column=$2
  geometry_type=$3
  target_srid=$4
  echo "starting $tablenamewithschema"
  psql -c "ALTER TABLE $tablenamewithschema ALTER COLUMN $geometry_column TYPE Geometry($geometry_type, $target_srid) USING ST_Transform($geometry_column, $target_srid);"
  echo "$tablenamewithschema done"
}

get_tables_in_schema () {
  schemaname=$1
  psql -c "SELECT tablename from pg_tables where schemaname = '$schemaname'" | awk '{print $1}' | tail -n +3 | head -n -2
}


main "$@"
