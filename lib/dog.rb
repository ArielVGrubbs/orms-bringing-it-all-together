class Dog
    attr_accessor :name, :breed, :id
    def initialize (dog_hash)
        @name = dog_hash[:name]
        @breed = dog_hash[:breed]
        @id = dog_hash[:id]
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
                )"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def self.create(hash)
        new_dog = self.new(hash)
        new_dog.save
    end

    def self.new_from_db (row)
        temp_hash = {name: row[1], breed: row[2], id: row[0]}
        # binding.pry
        Dog.new(temp_hash)
    end

    def self.find_by_id (id)
        temp_row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)
        Dog.new_from_db(temp_row.flatten)
    end

    def self.find_or_create_by (name:, breed:)
        # binding.pry
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = dog[0]
            # Dog.new_from_db(dog_data)
            temp_hash = {name: dog_data[1], breed: dog_data[2], id: dog_data[0]}
            dog = Dog.new(temp_hash)
          else
            dog = self.create(name: name, breed: breed)
          end
        # binding.pry
        dog
    end

    def self.find_by_name (name)
        new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        # binding.pry
        Dog.new_from_db(new_dog.flatten)
    end

    def save
        if self.id
          self.update
        else
          sql = "INSERT INTO dogs (name, breed)
            VALUES (?, ?)"
      
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        # DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", @id)
        self
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end
end