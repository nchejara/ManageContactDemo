const contacts = require("../models").contacts


module.exports = {
    create(req, res) {
        return contacts.create({
            name: req.body.name,
            email: req.body.email,
            mobile_number: req.body.mobile_number
        }).then(contact => res.status(201).send(contact))
      .catch(error => res.status(400).send(error));
    },
    
    list(req, res) {
        return contacts.findAll()
            .then(items => res.status(200).send(items))
            .catch(error => res.status(400).send(error));
    },

    delete(req, res) {
        return contacts
            .findByPk(req.params.id)
            .then(contact => {
                
                if(!contact)
                    return res.status(400).send({message: 'Contact Not Found'})
                
                return contact
                    .destroy()
                    .then(() => res.status(204).send())
                    .catch(error => res.status(400).send(error));
            })
            .catch(error => res.status(400).send(error))
    }  
}