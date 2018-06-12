require_relative "../config/environment.rb"

# access your database connection with DB[:conn]

class Student
  attr_accessor :name, :grade
  attr_reader :id 
  
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    
    DB[:conn].execute(sql)
  end
  
  def save
    if @id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
      SQL
      
      DB[:conn].execute(sql, @name, @grade)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end
  end
  
  def self.create(name, grade)
    self.new(name, grade).tap { |student| student.save }
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    
    self.new(name, grade, id)
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1;
    SQL
    
    student_data = DB[:conn].execute(sql, name)
    student_data.map { |row| self.new_from_db(row) }.first
  end
  
  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;
    SQL
    
    DB[:conn].execute(sql, @name, @grade, @id)
  end  
end
