class App.Ticket extends App.Model
  @configure 'Ticket', 'number', 'title', 'group_id', 'owner_id', 'customer_id', 'state_id', 'priority_id', 'article', 'tags', 'updated_at'
  @extend Spine.Model.Ajax
  @url: @apiPath + '/tickets'
  @configure_attributes = [
      { name: 'number',                display: '#',            tag: 'input',    type: 'text', limit: 100, null: true, readonly: 1, width: '68px' },
      { name: 'title',                 display: 'Title',        tag: 'input',    type: 'text', limit: 100, null: false },
      { name: 'customer_id',           display: 'Customer',     tag: 'input',    type: 'text', limit: 100, null: false, autocapitalize: false, relation: 'User' },
      { name: 'organization_id',       display: 'Organization', tag: 'select',   relation: 'Organization', readonly: 1 },
      { name: 'group_id',              display: 'Group',        tag: 'select',   multiple: false, limit: 100, null: false, relation: 'Group', width: '10%', edit: true },
      { name: 'owner_id',              display: 'Owner',        tag: 'select',   multiple: false, limit: 100, null: true, relation: 'User', width: '12%', edit: true },
      { name: 'state_id',              display: 'State',        tag: 'select',   multiple: false, null: false, relation: 'TicketState', default: 'new', width: '12%', edit: true, customer: true },
      { name: 'pending_time',          display: 'Pending Time', tag: 'datetime', null: true, width: '130px' },
      { name: 'priority_id',           display: 'Priority',     tag: 'select',   multiple: false, null: false, relation: 'TicketPriority', default: '2 normal', width: '12%', edit: true, customer: true },
      { name: 'article_count',         display: 'Article#',     readonly: 1, width: '12%' },
      { name: 'escalation_time',       display: 'Escalation',              tag: 'datetime', null: true, readonly: 1, width: '110px', class: 'escalation' },
      { name: 'last_contact',          display: 'Last contact',            tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'last_contact_agent',    display: 'Last contact (Agent)',    tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'last_contact_customer', display: 'Last contact (Customer)', tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'first_response',        display: 'First response',          tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'close_time',            display: 'Close time',              tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'created_by_id',         display: 'Created by',   relation: 'User', readonly: 1 },
      { name: 'created_at',            display: 'Created at',   tag: 'datetime', width: '110px', align: 'right', readonly: 1 },
      { name: 'updated_by_id',         display: 'Updated by',   relation: 'User', readonly: 1 },
      { name: 'updated_at',            display: 'Updated at',   tag: 'datetime', width: '110px', align: 'right', readonly: 1 },
    ]

  uiUrl: ->
    '#ticket/zoom/' + @id

  getState: ->
    type = App.TicketState.find( @state_id )
    stateType = App.TicketStateType.find( type.state_type_id )
    state = 'closed'
    if stateType.name is 'new' || stateType.name is 'open'
      state = 'open'

      # if ticket is escalated, overwrite state
      if @escalation_time && new Date( Date.parse( @escalation_time ) ) < new Date
        state = 'escalating'
    else if stateType.name is 'pending reminder'
      state = 'pending'

      # if ticket pending_time is reached, overwrite state
      if @pending_time && new Date( Date.parse( @pending_time ) ) < new Date
        state = 'open'
    else if stateType.name is 'pending action'
      state = 'pending'
    state

  icon: ->
    'task-state'

  iconClass: ->
    @getState()

  iconTitle: ->
    type = App.TicketState.find( @state_id )
    stateType = App.TicketStateType.find( type.state_type_id )
    if stateType.name is 'pending reminder' && @pending_time && new Date( Date.parse( @pending_time ) ) < new Date
      return "#{App.i18n.translateInline(type.displayName())} - #{App.i18n.translateInline('reached')}"
    if @escalation_time && new Date( Date.parse( @escalation_time ) ) < new Date
      return "#{App.i18n.translateInline(type.displayName())} - #{App.i18n.translateInline('escalated')}"
    App.i18n.translateInline(type.displayName())

  iconTextClass: ->
    "task-state-#{ @getState() }-color"

  iconActivity: (user) ->
    if @owner_id == user.id
      return 'important'
    ''
  searchResultAttributes: ->
    display:    "##{@number} - #{@title}"
    id:         @id
    class:      "task-state-#{ @getState() } ticket-popover"
    url:        @uiUrl()
    icon:       'task-state'
    iconClass:  @getState()
