resource "google_sql_database_instance" "master" {
  name = "master-instance"
  region = "europe-west1"

  settings {
    tier = "D0"
  }
}

resource "google_sql_database" "users" {
  name      = "users-db"
  instance  = "${google_sql_database_instance.master.name}"
  charset   = "latin1"
  collation = "latin1_swedish_ci"
}
