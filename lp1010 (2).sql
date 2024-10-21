from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, Table
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker


DATABASE_URI = f"mysql+pymysql://root:2609@localhost:3306/vk"
engine = create_engine(DATABASE_URI, echo=False)
Base = declarative_base()


friends_association = Table('friends', Base.metadata,
                            Column('user_id', Integer, ForeignKey('users.id')),
                            Column('friend_id', Integer, ForeignKey('users.id'))
                            )



class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, autoincrement=True)
    firstname = Column(String(50), nullable=False)
    lastname = Column(String(50), nullable=False)
    email = Column(String(80), nullable=False, unique=True)
    phone = Column(String(20), nullable=False, unique=True)


    friends = relationship('User',
                           secondary=friends_association,
                           primaryjoin=id == friends_association.c.user_id,
                           secondaryjoin=id == friends_association.c.friend_id)

    def __repr__(self):
        return f"<User(id={self.id}, name={self.firstname} {self.lastname}, email={self.email}, phone={self.phone})>"



Base.metadata.create_all(engine)


Session = sessionmaker(bind=engine)
session = Session()





def add_user(firstname, lastname, email, phone):
    new_user = User(firstname=firstname, lastname=lastname, email=email, phone=phone)
    session.add(new_user)
    session.commit()
    print(f"Пользователь {firstname} {lastname} добавлен успешно.")



def delete_user(user_id):
    user = session.query(User).filter_by(id=user_id).first()
    if user:
        session.delete(user)
        session.commit()
        print(f"Пользователь с ID {user_id} был удален.")
    else:
        print(f"Пользователь с ID {user_id} не найден.")



def edit_user(user_id, firstname=None, lastname=None, email=None, phone=None):
    user = session.query(User).filter_by(id=user_id).first()
    if user:
        if firstname:
            user.firstname = firstname
        if lastname:
            user.lastname = lastname
        if email:
            user.email = email
        if phone:
            user.phone = phone
        session.commit()
        print(f"Информация о пользователе с ID {user_id} была обновлена.")
    else:
        print(f"Пользователь с ID {user_id} не найден.")



def find_user_by_name(firstname, lastname):
    users = session.query(User).filter_by(firstname=firstname, lastname=lastname).all()
    if users:
        for user in users:
            print(
                f"Найден пользователь: ID={user.id}, Имя={user.firstname}, Фамилия={user.lastname}, Email={user.email}, Телефон={user.phone}.")
    else:
        print(f"Пользователь с именем {firstname} и фамилией {lastname} не найден.")



def add_friend(user_id, friend_id):
    user = session.query(User).filter_by(id=user_id).first()
    friend = session.query(User).filter_by(id=friend_id).first()

    if user and friend:
        user.friends.append(friend)
        session.commit()
        print(f"Пользователь с ID {user_id} добавил в друзья пользователя с ID {friend_id}.")
    else:
        print(f"Один из пользователей не найден.")



if __name__ == "__main__":
   
    add_user("Join", "Smit", "gail.lockman@example.net", "9251017068")
    add_user("Alyce", "Leuschke", "russel.ewell@example.com", "9461791942")

    
    find_user_by_name("Join", "Smit")

    
    edit_user(1, phone="9461791942")

   
    add_friend(1, 2)

    
    delete_user(2)

###########################################################################################

