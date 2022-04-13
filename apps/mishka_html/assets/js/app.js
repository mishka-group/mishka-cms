// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import topbar from "../vendor/topbar"
import {LiveSocket} from "phoenix_live_view"
// import "regenerator-runtime/runtime.js";
import ClassicEditor from "../static/js/ckeditor"

let Hooks = {}
Hooks.Calendar = {
  mounted() {
      var calendar = new FullCalendar.Calendar(this.el, {
        headerToolbar: {
          left: 'prev,next today',
          center: 'dayGridMonth',
          right: 'title'
        },
        initialDate: '2021-09-12',
        navLinks: true,
        selectable: true,
        selectMirror: true,
        select: function(arg) {
          var title = prompt('Event Title:');
          if (title) {
            calendar.addEvent({
              title: title,
              start: arg.start,
              end: arg.end,
              allDay: arg.allDay
            })
          }
          calendar.unselect()
        },
        eventClick: function(arg) {
          if (confirm('Are you sure you want to delete this event?')) {
            arg.event.remove()
          }
        },
        editable: true,
        dayMaxEvents: true, // allow "more" link when too many events
        events: [
          {
            title: 'All Day Event',
            start: '2021-09-01'
          },
          {
            title: 'Long Event',
            start: '2021-09-07',
            end: '2021-09-10'
          },
          {
            groupId: 999,
            title: 'Repeating Event',
            start: '2021-09-09T16:00:00'
          },
          {
            groupId: 999,
            title: 'Repeating Event',
            start: '2021-09-16T16:00:00'
          },
          {
            title: 'Conference',
            start: '2021-09-11',
            end: '2021-09-13',
            color: "#dadada"
          },
          {
            title: 'Meeting',
            start: '2021-09-12T10:30:00',
            end: '2021-09-12T12:30:00',
            color: "green"
          },
          {
            title: 'Lunch',
            start: '2021-09-12T12:00:00'
          },
          {
            title: 'Meeting',
            start: '2021-09-12T14:30:00'
          },
          {
            title: 'Happy Hour',
            start: '2021-09-12T17:30:00'
          },
          {
            title: 'Dinner',
            start: '2021-09-12T20:00:00'
          },
          {
            title: 'Birthday Party',
            start: '2021-09-13T07:00:00'
          },
          {
            title: 'Click for Google',
            url: 'http://google.com/',
            start: '2021-09-28',
            color: "green"
          }
        ]
      });
  
      calendar.render();
    // });
  }
}

function onClick(client_side_code) {
  grecaptcha.ready(function() {
    grecaptcha.execute(client_side_code, {action: 'submit'}).then(function(token) {
        filed = document.getElementById("g-recaptcha-response").value = token;
    });
  });
}

Hooks.GooglereCAPTCHA = {
  mounted() {
    this.handleEvent("update_recaptcha", ({client_side_code}) => {
      onClick(client_side_code)
    });
  }
}

Hooks.TextSearch = {
  mounted() {
    this.handleEvent("update_text_search", ({value}) => {
      document.getElementById("text_search").value = value;
    });
  }
}

Hooks.ReplyComment = {
  mounted() {
    this.handleEvent("jump_to_comment_form", (value) => {
      var element = document.getElementById("client-blog-post-comment-sending-box");
      element.scrollIntoView();
      if (value.description != null) {
        document.getElementById("client-blog-post-description").value = value.description;
      }
    });
  }
}

Hooks.Paginate = {
  mounted() {
    this.handleEvent("jump_to_top_page", (value) => {
      window.scroll({top: 0, left: 0, behavior: 'smooth'});
    });
  }
}

const ckeditorItems = ['heading', '|', 'bold', 'italic', 'link', 'bulletedList', 'numberedList', '|', 'outdent', 'indent', '|', 
  'blockQuote', 'insertTable', 'undo','redo','fontSize','highlight','pageBreak','todoList','alignment','-','code',
  'codeBlock', 'findAndReplace', 'fontBackgroundColor', 'fontColor', 'horizontalLine', '|', 'imageInsert', 'removeFormat', 
  'sourceEditing', 'specialCharacters', 'restrictedEditingException', 'strikethrough', 'underline', 'textPartLanguage', 
  '|', 'htmlEmbed'
]

var theEditor = null;
Hooks.Editor = {
  mounted() {
    var container = document.querySelector("#editor");
    const view = this;
    var serverHtml = "";
    if (container != null) {
      ClassicEditor
      .create(container, {
        toolbar: {
					items: ckeditorItems,
					shouldNotGroupWhenFull: true
				},
				language: 'en',
				alignment: {
					options: [
						{ name: 'left', className: 'my-align-left' },
						{ name: 'right', className: 'my-align-right' }
					]
				},
				image: {
					toolbar: ['linkImage', 'imageTextAlternative', 'imageStyle:inline', 'imageStyle:block', 'imageStyle:side', 'toggleImageCaption']
				},
				table: {
					contentToolbar: ['tableColumn', 'tableRow', 'mergeTableCells', 'tableCellProperties', 'tableProperties']
				},
					licenseKey: '',
				} )
				.then( new_editor => {
					window.editor = new_editor;
          new_editor.setData(serverHtml);
          theEditor = new_editor; // Save for later use.
					editor.model.document.on('change:data', (eventInfo, batch ) => {
						var data = { html: editor.getData()};
    					view.pushEvent("save-editor", data);
					});
					
				} )
				.catch( error => {
					console.error( 'Oops, something went wrong!' );
					console.error( error );
				} );

      this.handleEvent("update-editor-html", ({html}) => {
        console.log(html)
        serverHtml = html;
        if (theEditor != null) {
          theEditor.setData(html);
        }
      });
    }
  }
}

Hooks.DeleteFlashMessage = {
    mounted() {
      this.handleEvent("delete_flash_message", ({id}) => {
        const element = document.getElementById(id);
        element.remove();
      });
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})



// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket