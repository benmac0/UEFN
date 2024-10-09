// Define the Survivor class
class Survivor {
  var name: String
  var level: Int
  var experience: Int
  var experienceNeeded: Int
  var strength: Int
  var agility: Int
  var intelligence: Int
  var mana: Int
  var stealth: Int
  var lockpicking: Int

  // Constructor
  new(name: String) {
    self.name = name
    self.level = 1
    self.experience = 0
    self.experienceNeeded = 100
    self.strength = 10
    self.agility = 5
    self.intelligence = 15
    self.mana = 100
    self.stealth = 10
    self.lockpicking = 5
  }

  // Level up method
  method levelUp() {
    self.level += 1
    self.experience = 0
    self.experienceNeeded = self.experienceNeeded * 1.5
    self.strength += 2
    self.agility += 1
    self.intelligence += 3
    self.mana += 20
    self.stealth += 2
    self.lockpicking += 1
  }

  // Gain experience method
  method gainExperience(amount: Int) {
    self.experience += amount
    if self.experience >= self.experienceNeeded {
      self.levelUp()
    }
  }
}

// Create a new Survivor
var survivor = Survivor("John")

// Simulate some gameplay
survivor.gainExperience(50)
survivor.gainExperience(75)
survivor.gainExperience(25)
survivor.gainExperience(50)
survivor.gainExperience(75)
survivor.gainExperience(25)

// Print out the Survivor's stats
print(survivor.name + "'s stats:")
print("Level: " + survivor.level)
print("Strength: " + survivor.strength)
print("Agility: " + survivor.agility)
print("Intelligence: " + survivor.intelligence)
print("Mana: " + survivor.mana)
print("Stealth: " + survivor.stealth)
print("Lockpicking: " + survivor.lockpicking)