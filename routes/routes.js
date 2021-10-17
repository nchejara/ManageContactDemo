const contactsController = require("../server/controllers/contacts")
const contacts = require("../server/models").contacts

module.exports = function(app){

    app.get('/', (req, res) => {
        var renderData = {
            title: 'Manage Contacts Demo Application',
            author: {name: 'Naren Chejara', details:'https://medium.com/@narenchejara'},
            contacts: []
        }

        
        contacts.findAll({attributes: ['id', 'name','email','mobile_number'], raw: true})
            .then(items => {
                renderData.contacts = items;
                console.log(renderData.contacts);
                res.status(200).render('index', renderData);
            })
            .catch(error => res.status(400).send(error));

        // res.render('index', renderData);
    });

    app.get('/add_contact', (req, res) => {
        return res.redirect("/");
    });
    app.post('/add_contact', (req, res) => {
        contacts.create({
            name: req.body.name,
            email: req.body.email,
            mobile_number: req.body.mobile_number

        }).then(contact => res.status(200).redirect("/"))
      .catch(error => res.status(400).send(error));
    })
    
    app.get("/delete/:id", (req, res) => {
        return contacts
            .findByPk(req.params.id)
            .then(contact => {
                
                if(!contact)
                    return res.status(400).send({message: 'Contact Not Found'})
                
                return contact
                    .destroy()
                    .then(() => res.status(204).redirect("/"))
                    .catch(error => res.status(400).send(error));
            })
            .catch(error => res.status(400).send(error))
    })
    app.get('/api', (req, res) => res.status(200).send({
        message: "Welcome to the Manage Contact API!",
    }));

    app.post("/api/create", contactsController.create);
    app.get("/api/contact_list", contactsController.list);
    app.get("/api/delete/:id", contactsController.delete);
}