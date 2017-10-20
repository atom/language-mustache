describe 'Mustache grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-html')

    waitsForPromise ->
      atom.packages.activatePackage('language-mustache')

    runs ->
      grammar = atom.grammars.grammarForScopeName('text.html.mustache')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'text.html.mustache'

  it 'parses expressions', ->
    {tokens} = grammar.tokenizeLine("{{name}}")

    expect(tokens[0]).toEqual value: '{{', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']
    expect(tokens[1]).toEqual value: 'name', scopes: ['text.html.mustache', 'meta.tag.template.mustache']
    expect(tokens[2]).toEqual value: '}}', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']

  it 'parses expressions in HTML attributes', ->
    # TODO: Remove after Atom 1.21 is released
    scopes = null
    if parseFloat(atom.getVersion()) <= 1.21
      scopes = ['meta.tag.any.html']
    else
      scopes = ['meta.tag.inline.a.html', 'meta.attribute-with-value.html']

    {tokens} = grammar.tokenizeLine("<a href='{{test}}'></a>")

    expect(tokens[6]).toEqual value: '{{', scopes: ['text.html.mustache', scopes..., 'string.quoted.single.html', 'meta.tag.template.mustache', 'entity.name.tag.mustache']
    expect(tokens[8]).toEqual value: '}}', scopes: ['text.html.mustache', scopes..., 'string.quoted.single.html', 'meta.tag.template.mustache', 'entity.name.tag.mustache']
    expect(tokens[9]).toEqual value: "'", scopes: ['text.html.mustache', scopes..., 'string.quoted.single.html', 'punctuation.definition.string.end.html']

  it 'parses block comments', ->
    {tokens} = grammar.tokenizeLine("{{!--{{comment}}--}}")

    expect(tokens[0]).toEqual value: '{{!--', scopes: ['text.html.mustache', 'comment.block.mustache', 'punctuation.definition.comment.mustache']
    expect(tokens[1]).toEqual value: '{{comment}}', scopes: ['text.html.mustache', 'comment.block.mustache']
    expect(tokens[2]).toEqual value: '--}}', scopes: ['text.html.mustache', 'comment.block.mustache', 'punctuation.definition.comment.mustache']

  it 'parses comments', ->
    {tokens} = grammar.tokenizeLine("{{!comment}}")

    expect(tokens[0]).toEqual value: '{{!', scopes: ['text.html.mustache', 'comment.block.mustache', 'punctuation.definition.comment.mustache']
    expect(tokens[1]).toEqual value: 'comment', scopes: ['text.html.mustache', 'comment.block.mustache']
    expect(tokens[2]).toEqual value: '}}', scopes: ['text.html.mustache', 'comment.block.mustache', 'punctuation.definition.comment.mustache']

  it 'parses block expression', ->
    {tokens} = grammar.tokenizeLine("{{#each people}}")

    expect(tokens[0]).toEqual value: '{{', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']
    expect(tokens[1]).toEqual value: '#', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache', 'punctuation.definition.block.begin.mustache']
    expect(tokens[2]).toEqual value: 'each', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache', 'entity.name.function.mustache']
    expect(tokens[3]).toEqual value: ' people', scopes: ['text.html.mustache', 'meta.tag.template.mustache']
    expect(tokens[4]).toEqual value: '}}', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']

    {tokens} = grammar.tokenizeLine("{{# nested.block }}")

    expect(tokens[0]).toEqual value: '{{', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']
    expect(tokens[1]).toEqual value: '#', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache', 'punctuation.definition.block.begin.mustache']
    expect(tokens[3]).toEqual value: 'nested.block', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache', 'entity.name.function.mustache']
    expect(tokens[5]).toEqual value: '}}', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']

    {tokens} = grammar.tokenizeLine("{{^repo}}")

    expect(tokens[0]).toEqual value: '{{', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']
    expect(tokens[1]).toEqual value: '^', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache', 'punctuation.definition.block.begin.mustache']
    expect(tokens[2]).toEqual value: 'repo', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache', 'entity.name.function.mustache']
    expect(tokens[3]).toEqual value: '}}', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']

    {tokens} = grammar.tokenizeLine("{{/if}}")

    expect(tokens[0]).toEqual value: '{{', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']
    expect(tokens[1]).toEqual value: '/', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache', 'punctuation.definition.block.end.mustache']
    expect(tokens[2]).toEqual value: 'if', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache', 'entity.name.function.mustache']
    expect(tokens[3]).toEqual value: '}}', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']

  it 'parses unescaped expressions', ->
    {tokens} = grammar.tokenizeLine("{{{do not escape me}}}")

    expect(tokens[0]).toEqual value: '{{{', scopes: ['text.html.mustache', 'meta.tag.template.raw.mustache', 'entity.name.tag.mustache']
    expect(tokens[1]).toEqual value: 'do not escape me', scopes: ['text.html.mustache', 'meta.tag.template.raw.mustache']
    expect(tokens[2]).toEqual value: '}}}', scopes: ['text.html.mustache', 'meta.tag.template.raw.mustache', 'entity.name.tag.mustache']

  it 'does not tokenize tags within tags', ->
    {tokens} = grammar.tokenizeLine("{{test{{test}}}}")

    expect(tokens[0]).toEqual value: '{{', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']
    expect(tokens[1]).toEqual value: 'test{{test', scopes: ['text.html.mustache', 'meta.tag.template.mustache']
    expect(tokens[2]).toEqual value: '}}', scopes: ['text.html.mustache', 'meta.tag.template.mustache', 'entity.name.tag.mustache']
    expect(tokens[3]).toEqual value: '}}', scopes: ['text.html.mustache']

  it 'does not tokenize comments within comments', ->
    {tokens} = grammar.tokenizeLine("{{!test{{!test}}}}")

    expect(tokens[0]).toEqual value: '{{!', scopes: ['text.html.mustache', 'comment.block.mustache', 'punctuation.definition.comment.mustache']
    expect(tokens[1]).toEqual value: 'test{{!test', scopes: ['text.html.mustache', 'comment.block.mustache']
    expect(tokens[2]).toEqual value: '}}', scopes: ['text.html.mustache', 'comment.block.mustache', 'punctuation.definition.comment.mustache']
    expect(tokens[3]).toEqual value: '}}', scopes: ['text.html.mustache']
