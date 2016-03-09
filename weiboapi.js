//////////////////////////////////////////////////////////////////////////////////////     weibo
//home status
function weiboHomeStatus(token, page , observer)
{
    var url = "https://api.weibo.com/2/statuses/home_timeline.json?access_token=" + token + "&page=" + page

    console.log("home status start...")
    console.log("url: " + url);

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" home status in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!Network connection failed!")
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- home status succeeded !");

                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        // console.log("home status: done" + doc.responseText)
                        console.log("Some data received!")
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

function getStatus() {
    // We can get some data from the web and display them
    console.log("Going to get some data from web")
    function observer() {}
    observer.prototype = {
        update: function(status, result)
        {
            console.log("got updated!");

            if(status != "error"){
                if( result.error ) {
                    console.log("result.error: " + result.error);
                }else {
                    console.log("got updated1!");
                    for ( var i = 0; i < result.statuses.length; i++) {
                        modelWeibo.append( result.statuses[i] )
                    }
                }
            }else{
                console.log("Something is wrong!");
            }
        }
    }

    weiboHomeStatus(main.accesstoken, 1, new observer() );
}

