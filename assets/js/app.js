'use strict';

// Melhoria opcional: o estoque continua visível nas opções sem JavaScript.
const livro = document.getElementById('livro_id');
const ajuda = document.getElementById('estoque-ajuda');
if (livro && ajuda) {
    const atualizarEstoque = () => {
        const opcao = livro.options[livro.selectedIndex];
        ajuda.textContent = opcao && opcao.dataset.estoque !== undefined
            ? `Estoque atual: ${opcao.dataset.estoque} exemplar(es).`
            : 'A quantidade disponível aparece ao lado do título.';
    };
    livro.addEventListener('change', atualizarEstoque);
    atualizarEstoque();
}
