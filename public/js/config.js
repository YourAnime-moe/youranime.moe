var Config = (function() {

    function getParameterByName(name, url) {
        if (!url) url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    }

    function insertParam(key, value) {
        key = encodeURI(key); value = encodeURI(value);
        var kvp = document.location.search.substr(1).split('&');
        var i=kvp.length; var x; while(i--) {
            x = kvp[i].split('=');
            if (x[0]==key) {
                x[1] = value;
                kvp[i] = x.join('=');
                break;
            }
        }
        if(i<0) {kvp[kvp.length] = [key,value].join('=');}
        document.location.search = kvp.join('&');
    }

    function getChildWithID(element, id) {
        if (!element || element.children === undefined) return;
        if (element.id == id) {
            return element;
        }
        for (var i = 0; i < element.children.length; i++) {
            var res = getChildWithID(element.children[i], id);
            if (res !== null) {
                return res;
            }
        }
        return null;
    }

    return {
        getParameterByName: getParameterByName,
        insertParam: insertParam,
        getChildWithID: getChildWithID
    }

})();
