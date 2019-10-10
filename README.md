<img src="https://i.imgur.com/VdBlP49.png" alt="Alexandria logo">

A website for uploading, managing, and organizing Magic: the Gathering decklists.

**[Link to Frontend](https://github.com/JKDMarks/alexandria-frontend/)**

## Inspiration

There are many MTG decklists websites online, but no one of them has all of the features that I desired. *Alexandria* was created as a way to integrate all of these features.

## Features and Challenges

Database built using PostgreSQL.

Uses various **has_many through** domain model connections to relate Users, Decks, and Cards. 

Has authentication using the BCrypt and JWT gems. 

## Built With

* [Ruby on Rails](https://rubyonrails.org/) - Used as a RESTful API built on top of a SQL database
* [PostgreSQL](https://www.postgresql.org/) - Database
* [BCrypt](https://github.com/codahale/bcrypt-ruby) - Password hashing
* [JWT](https://github.com/jwt/ruby-jwt) - JSON Web Token OAuth
* [ActiveModel Serializer](https://github.com/rails-api/active_model_serializers) - Gem that shapes return data

## Notes

Named after the [famous card](https://scryfall.com/card/arn/76/library-of-alexandria) and the (more) famous library. In Magic your deck is called a library.
